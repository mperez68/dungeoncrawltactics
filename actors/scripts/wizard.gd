extends PlayerActor

class_name Wizard

func init_specials():
	spell_book.push_front(preload("res://actions/immolate.tscn").instantiate())
	
func gen_name():
	NAME = [ "Inarhan", "Philess", "Phasim", "Rubras" ].pick_random() + " of The " + [ "Whispering", "Cloud", "Dark", "Royal" ].pick_random() + " " + [ "Peaks", "Obelisk", "Spire", "Tower" ].pick_random()
