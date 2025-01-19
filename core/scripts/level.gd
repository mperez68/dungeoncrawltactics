extends Node

signal new_turn_order(actors: Array[Actor])
signal enable_ui(enable: bool)
signal inc_turn_counter(turn: int)

# References
@onready var end_dialog = $EndGameDialog
@onready var map = $Map
@onready var pause = $TurnPauseTimer

# Constants
const PAUSE_LONG: float = 1
const PAUSE_SHORT: float = 0.1

var actors: Array[Actor] = []
var non_actors: Array[Actor] = []
var objectives: Array[Vector2] = []
var active: int = -1
var turn_counter = 0


# engine
func _ready() -> void:
	# populate actors lists
	for child in find_children("*", "Actor"):
		if child.is_actor:
			actors.push_back(child)
		else:
			non_actors.push_front(child)
	# Shuffle, assign their index in actor node
	actors.shuffle()
	for i in actors.size():
		actors[i].index = i
	# Transmit to HUD
	new_turn_order.emit(actors)
	
	pass_turn()

func _on_timer_timeout() -> void:
	enable_ui.emit(get_active().is_sig)
	await actors[active].start_turn()


# UI
func _on_hud_button_pressed(select_type: int) -> void:
	actors[active].select(select_type)

func _on_hud_end_turn() -> void:
	actors[active].end_turn()

func _on_hud_spell_pressed(spell: int) -> void:
	actors[active].spell_pointer = spell
	actors[active].select(Actor.SELECT_TYPE_SPELL)

func _on_hud_ability_pressed(ability: int) -> void:
	actors[active].ability_pointer = ability
	actors[active].select(Actor.SELECT_TYPE_ABILITY)

func _on_hud_inventory_pressed(item: int) -> void:
	actors[active].inventory_pointer = item
	actors[active].select(Actor.SELECT_TYPE_INVENTORY)


# public methods
func pass_turn():
	map.clear_highlights()
	if !pause.is_stopped():
		return
	enable_ui.emit(false)
	# End game if all enemies or allies are killed
	match is_conflict():
		1:
			enable_ui.emit(false)
			end_dialog.dialog_text = "ALL ENEMIES SLAIN, YOU CAN LEAVE SAFELY"
			end_dialog.visible = true
			return
		-1:
			print("player loses")
			enable_ui.emit(false)
			end_dialog.dialog_text = "YOU DIED"
			end_dialog.visible = true
			return
	# Edge case, no actors
	if actors.is_empty():
		enable_ui.emit(false)
		end_dialog.dialog_text = "NOBODY LIVED"
		end_dialog.visible = true
		return
	var time = PAUSE_LONG
	if !actors[active].visible:
		time = PAUSE_SHORT
	# Iterate through actors list until a living actor is found
	while(true):
		active = (active + 1) % actors.size()
		if active == 0:
			turn_counter += 1
			inc_turn_counter.emit(turn_counter)
		if (actors[active].hp > 0):
			break
	
	pause.start(time)

func get_active() -> Actor:
	if !actors or active < 0 or active >= actors.size():
		return null
	return actors[active]

func get_all_actors() -> Array[Actor]:
	var ret: Array[Actor] = []
	ret.append_array(actors)
	ret.append_array(non_actors)
	return ret

func get_actors_at_position(origin: Vector2, radius:int = 0) -> Array:
	var result = []
	for actor in actors:
		if map.can_see(origin, actor.position, radius) and actor.hp > 0:
			result.push_front(actor)
	return result

func get_non_actors_at_position(origin: Vector2) -> Array[Actor]:
	var result: Array[Actor] = []
	for actor in non_actors:
		if map.local_to_map(origin) == map.local_to_map(actor.position):
			result.push_back(actor)
	
	return result

func remove_non_actors_at_position(origin: Vector2) -> Array[Actor]:
	var result: Array[Actor] = []
	for i in range(non_actors.size() - 1, -1, -1):
		if map.local_to_map(origin) == map.local_to_map(non_actors[i].position):
			result.push_back(non_actors[i])
			non_actors[i].queue_free()
			non_actors.remove_at(i)
	
	return result

func add_objective(objective: Vector2):
	objectives.push_back(objective)

func end_game():
	enable_ui.emit(false)
	end_dialog.visible = true

# private methods
func is_conflict() -> int:
	var sig_ct = 0
	var insig_ct = 0
	
	for actor in actors:
		if actor.hp > 0:
			if actor.is_sig:
				sig_ct += 1
			else:
				insig_ct += 1
	
	
	sig_ct = min(sig_ct, 1)
	insig_ct = min(insig_ct, 1)
	return sig_ct - insig_ct
