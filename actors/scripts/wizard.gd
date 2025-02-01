extends PlayerActor

class_name Wizard

const name1: Array[String] = [ "Inarhan", "Philess", "Phasim", "Rubras", "Usior", "Qadel", "Oveus", "Thutaz", "Edeqium", "Eqia", "Frevys", "Ofaris" ]
const name2: Array[String] = [ "Whispering", "Cloud", "Dark", "Royal", "Chaos", "Wandering", "Fading", "Death" ]
const name3: Array[String] = [ "Peaks", "Obelisk", "Spire", "Tower", "Keep", "Wastes", "Watchers", "Keepers" ]

func gen_name():
	NAME = name1.pick_random() + " of The " + name2.pick_random() + " " + name3.pick_random()

func init_specials():
	spell_book.push_back(CharacterList.wizard_options.pick_random())
