extends Control

signal new_actor(actor: MenuActor)
signal roster_to_loadout(index: int)
signal loadout_to_roster(index: int)
signal deselect_roster
signal deselect_loadout

var roster_selection: int = -1
var loadout_selection: int = -1

func _on_add_pressed(player_class: String) -> void:
	var arg: MenuActor.Type = MenuActor.Type.DEFAULT
	var actor: MenuActor
	match player_class:
		"soldier":
			arg = MenuActor.Type.SOLDIER
		"archer":
			arg = MenuActor.Type.ARCHER
		"wizard":
			arg = MenuActor.Type.WIZARD
	actor = preload("res://ui/menu_actor.tscn").instantiate()
	actor.init(arg)
	
	new_actor.emit(actor)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_1.tscn")


func _on_roster_item_selected(index: int) -> void:
	roster_selection = index
	loadout_selection = -1
	deselect_loadout.emit()

func _on_add_to_loadout_pressed() -> void:
	if roster_selection < 0:
		return
	deselect_roster.emit()
	deselect_loadout.emit()
	roster_to_loadout.emit(roster_selection)
	loadout_selection = -1
	roster_selection = -1

func _on_roster_item_activated(index: int) -> void:
	deselect_roster.emit()
	deselect_loadout.emit()
	roster_to_loadout.emit(index)
	loadout_selection = -1
	roster_selection = -1


func _on_loadout_item_selected(index: int) -> void:
	loadout_selection = index
	roster_selection = -1
	deselect_roster.emit()

func _on_remove_from_loadout_pressed() -> void:
	if loadout_selection < 0:
		return
	deselect_roster.emit()
	deselect_loadout.emit()
	loadout_to_roster.emit(loadout_selection)
	loadout_selection = -1
	roster_selection = -1

func _on_loadout_item_activated(index: int) -> void:
	deselect_roster.emit()
	deselect_loadout.emit()
	loadout_to_roster.emit(index)
	loadout_selection = -1
	roster_selection = -1
