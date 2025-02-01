extends PlayerActor

class_name Archer

const name1: Array[String] = [ "Lhoris", "Eldrin", "Lyari", "Myrin", "Omaran", "Paragon", "Carlen", "Roceran", "Faena", "Gilleth" ]
const name2: Array[String] = [ "Quillrest", "Carfiel", "Iliric", "Of Springfern", "WIllow-watcher", "Oakenheart", "Flenor", "Greensense", "Farstalker" ]

func gen_name():
	NAME = name1.pick_random() + " " + name2.pick_random()

func init_specials():
	abilities.push_back(CharacterList.archer_options.pick_random())
