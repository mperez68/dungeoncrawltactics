extends Node

@onready var map = $Map

var actors = []
var active: int = -1

func _ready() -> void:
	for child in find_children("*", "Actor"):
		actors.push_front(child)
	actors.shuffle()
	$Timer.start()

func pass_turn():
	$Timer.start()

func _on_timer_timeout() -> void:
	if actors.is_empty():
		print("game over")
	while(true):
		active = (active + 1) % actors.size()
		if actors[active].hp > 0:
			break
	actors[active].start_turn()


func _on_hud_button_pressed(select_type: int) -> void:
	actors[active].select(select_type)


func _on_hud_end_turn() -> void:
	actors[active].end_turn()

func get_actors_at_position(origin: Vector2, radius:int = 0) -> Array:
	#var grid_pos = map.local_to_map(origin)
	var result = []
	for actor in actors:
		if map.can_see(origin, actor.position, radius) and actor.hp > 0:
		#if grid_pos == map.local_to_map(actor.position):
			result.push_front(actor)
	return result
