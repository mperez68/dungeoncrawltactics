extends ItemList

signal update_actor_panel(actor: MenuActor)

var loadout_list: Array[MenuActor] = []

func _ready():
	clear()
	# populate
	for actor in CharacterList.final_loadout:
		loadout_list.push_back(CharacterList.get_menu_actor_from_player_actor(actor))
		add_item(actor.NAME)


func _on_item_selected(index: int) -> void:
	update_actor_panel.emit(loadout_list[index])
