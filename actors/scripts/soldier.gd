extends PlayerActor

class_name Soldier

func _ready() -> void:
	super()
	NAME = [ "Charle", "Simmond", "Kester", "Joffridus" ].pick_random() + " the " + [ "Bear", "Bulwark", "Scar of Tiberos", "Persistent" ].pick_random()
