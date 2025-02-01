extends EquipmentActor

@export var target_range: int = 2

func _effect_vector(user: Actor, target: Vector2) -> bool:
	if target == Vector2.ZERO:
		map.draw_range(user.position, target_range)
	else:
		var this = get_parent()
		this.position = map.get_center(target)
		this.manager.add_child(this)
		this.manager.non_actors.push_back(this)
		return true
	return false
