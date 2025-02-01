extends Spell

class_name HealingTouch

func effect(target: Actor, _crit: bool):
	target.heal(3, 4, crit_modifier, crit_multiplier)
