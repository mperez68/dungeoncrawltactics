extends PlayerActor

class_name Archer

func gen_name():
	NAME = [ "Lhoris", "Eldrin", "Lyari", "Myrin" ].pick_random() + " " + [ "Quillrest", "Carfiel", "Iliric", "Of Springfern" ].pick_random()

func init_specials():
	pass
