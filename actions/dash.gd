extends Ability

class_name Dash

var target_range: int = 3

func _effect_vector(user: Actor, target: Vector2) -> bool:
	if target == Vector2.ZERO:
		map.draw_range(user.position, target_range)
	elif user.walk(target, target_range):
		return true
	return false
