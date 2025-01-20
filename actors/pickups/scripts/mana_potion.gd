extends Equipment

class_name ManaPotion

var min_restore = 1
var max_restore = 2

func _effect_no_target(user: Actor) -> bool:
	user.restore(min_restore, max_restore)
	return true
