extends Node

signal new_turn_order(actors: Array[Actor])
signal next_turn(index: int)

@onready var map = $Map
@onready var pause = $TurnPauseTimer

var actors: Array[Actor] = []
var active: int = -1


# engine
func _ready() -> void:
	for child in find_children("*", "Actor"):
		actors.push_front(child)
	actors.shuffle()
	for i in actors.size():
		actors[i].index = i
	new_turn_order.emit(actors)
	pause.start()

func _on_timer_timeout() -> void:
	if (!has_significant_actors()):
		print("all sigs dead")
	else:
		if actors.is_empty():
			print("game over")
		while(true):
			active = (active + 1) % actors.size()
			if actors[active].hp > 0:
				break
		next_turn.emit(active)
		actors[active].start_turn()


# UI
func _on_hud_button_pressed(select_type: int) -> void:
	actors[active].select(select_type)

func _on_hud_end_turn() -> void:
	actors[active].end_turn()


# public methods
func pass_turn():
	pause.start()

func get_active() -> Actor:
	if !actors or active < 0 or active >= actors.size():
		return null
	return actors[active]

func get_actors_at_position(origin: Vector2, radius:int = 0) -> Array:
	#var grid_pos = map.local_to_map(origin)
	var result = []
	for actor in actors:
		if map.can_see(origin, actor.position, radius) and actor.hp > 0:
		#if grid_pos == map.local_to_map(actor.position):
			result.push_front(actor)
	return result


# private methods
func has_significant_actors() -> bool:
	var ret = false
	
	for actor in actors:
		if actor.sig and actor.hp > 0:
			ret = true
	
	return ret
