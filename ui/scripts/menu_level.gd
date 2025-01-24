extends Node2D

@onready var map = $Map
@onready var camera = $Camera

var actor_list: Array[MenuActor] = []
var start_pos: Vector2i = Vector2i(7, 7)
var half_tile: Vector2 = Vector2(8, 8)

func add_actor(actor: MenuActor):
	actor.position = _get_position(start_pos + Vector2i(0, 2 *actor_list.size()))
	actor_list.push_back(actor)
	add_child(actor)
	_center_camera()

func remove_actor(index: int):
	if index >= actor_list.size():
		print("index ", index, " out of bounds")
		return
	var temp = actor_list[index]
	actor_list.remove_at(index)
	remove_child(temp)
	for i in actor_list.size():
		actor_list[i].position = _get_position(start_pos + Vector2i(0, 2 * i))
	_center_camera()

func _get_position(coords: Vector2i) -> Vector2:
	return (Vector2(coords) * 16) + half_tile

func _center_camera():
	var pos = Vector2.ZERO
	
	for actor in actor_list:
		pos += actor.position
	
	if actor_list.size() > 0:
		pos /= actor_list.size()
	else:
		pos = _get_position(start_pos)
	
	camera.position = pos
