extends Ability

class_name RapidShot

func _effect_actor(user: Actor, target: Actor) -> bool:
	if target == null:
		map.draw_range(user.position, int(floor(user.attack_range / 2)), false)
	elif map.can_see(user.position, target.position, int(floor(user.attack_range / 2))):
		target.attack(user)
		return true
	return false
