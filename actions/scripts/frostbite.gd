extends Spell

class_name Frostbite

func effect(target: Actor, crit: bool):
	target.WALK_RANGE -= int(floor(float(target.WALK_RANGE) / 2))
	if crit:
		target.WALK_RANGE -= int(floor(float(target.WALK_RANGE) / 2))
