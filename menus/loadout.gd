extends ItemList

signal send_to_roster(actor: MenuActor)
signal add_actor(actor: MenuActor)
signal remove_actor(index: int)
signal update_selected_actor(actor: MenuActor)
signal lock_loadout(is_locked: int)

var loadout: Array[MenuActor] = []

func _ready() -> void:
	clear()

func _on_pregame_screen_deselect_loadout() -> void:
	deselect_all()


func _on_pregame_screen_loadout_to_roster(index: int) -> void:
	if range(loadout.size()).has(index):
		send_to_roster.emit(loadout[index])
		loadout.remove_at(index)
		remove_item(index)
		remove_actor.emit(index)
		if loadout.size() < 3:
			lock_loadout.emit(false)


func _on_roster_send_to_loadout(actor: MenuActor) -> void:
	loadout.push_back(actor)
	add_item(actor.actor_name) #TODO add icon
	add_actor.emit(actor)
	if loadout.size() >= 3:
		lock_loadout.emit(true)


func _on_item_selected(index: int) -> void:
	update_selected_actor.emit(loadout[index])


func _on_start_pressed() -> void:
	CharacterList.final_loadout.clear()
	for actor in loadout:
		CharacterList.final_loadout.push_back(actor.actor_reference)
	get_tree().change_scene_to_file("res://levels/level_1.tscn")
