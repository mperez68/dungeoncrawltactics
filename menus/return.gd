extends ItemList


func _ready():
	clear()
	# populate
	for actor in CharacterList.final_loadout:
		add_item(actor.NAME)
