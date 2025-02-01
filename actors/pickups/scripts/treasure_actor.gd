extends EquipmentActor

@export var target_range: int = 2

func _effect_vector(user: Actor, target: Vector2) -> bool:
	if target == Vector2.ZERO:
		map.draw_range(user.position, target_range)
	else:
		position = map.get_center(target)
		user.manager.add_child(self)
		user.manager.non_actors.push_back(self)
		return true
	return false
