extends PlayerActor

class_name Wizard

func _ready() -> void:
	super()
	NAME = [ "inarhan", "philess", "Phasim", "Rubras" ].pick_random() + " of The " + [ "Whispering", "Cloud", "Dark", "Royal" ].pick_random() + " " + [ "Peaks", "Obelisk", "Spire", "Tower" ].pick_random()
