extends PlayerActor

class_name Archer

func _ready() -> void:
	super()
	NAME = [ "Lhoris", "Eldrin", "Lyari", "Myrin" ].pick_random() + " " + [ "Quillrest", "Carfiel", "Iliric", "Of Springfern" ].pick_random()
