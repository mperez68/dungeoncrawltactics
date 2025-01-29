extends Ability

class_name Block


func _effect_no_target(user: Actor) -> bool:
	user.temp_armor += 0.3
	return true
