extends PlayerActor

class_name Soldier

const name1: Array[String] = [ "Charle", "Simmond", "Kester", "Joffridus", "Szurand", "Kame", "Nizi", "Redul", "Kogny" ]
const name2: Array[String] = [ "Bear", "Bulwark", "Scar of Tiberos", "Persistent", "Grim", "Fury", "Ironshields", "Nightmare", "Blood Soaked" ]

func gen_name():
	NAME = name1.pick_random() + " the " + name2.pick_random()

func init_specials():
	abilities.push_back(CharacterList.soldier_options.pick_random())
