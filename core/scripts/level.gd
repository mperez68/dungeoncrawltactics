extends Node

signal new_turn_order(actors: Array[Actor])
signal enable_ui(enable: bool)

@onready var map = $Map
@onready var pause = $TurnPauseTimer

var actors: Array[Actor] = []
var non_actors: Array[Actor] = []
var objectives: Array[Vector2] = []
var active: int = -1


# engine
func _ready() -> void:
	for child in find_children("*", "Actor"):
		if child.is_actor:
			actors.push_front(child)
		else:
			non_actors.push_front(child)
	actors.shuffle()
	for i in actors.size():
		actors[i].index = i
	new_turn_order.emit(actors)
	pause.start()
	enable_ui.emit(false)

func _on_timer_timeout() -> void:
	match is_conflict():
		1:
			print("all enemies killed")
		-1:
			print("player loses")
			return
		
	if actors.is_empty():
		print("game over")
	while(true):
		active = (active + 1) % actors.size()
		if actors[active].hp > 0:
			break
	enable_ui.emit(get_active().is_sig)
	actors[active].start_turn()


# UI
func _on_hud_button_pressed(select_type: int) -> void:
	actors[active].select(select_type)

func _on_hud_end_turn() -> void:
	actors[active].end_turn()


# public methods
func pass_turn():
	enable_ui.emit(false)
	pause.start()

func get_active() -> Actor:
	if !actors or active < 0 or active >= actors.size():
		return null
	return actors[active]

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
