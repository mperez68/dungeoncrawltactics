extends Equipment

var target_range: int = 2

func _effect_vector(user: Actor, target: Vector2) -> bool:
	if target == Vector2.ZERO:
		map.draw_range(user.position, target_range)
	else:
		var n = node.instantiate()
		n.position = target
		user.manager.add_child(n)
		user.manager.non_actors.push_back(n)
		return true
	return false
