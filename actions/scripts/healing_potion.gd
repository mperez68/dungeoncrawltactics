extends Equipment

class_name HealingPotion

var min_heal = 2
var max_heal = 3

func _effect_no_target(user: Actor) -> bool:
	user.heal(min_heal, max_heal)
	return true
