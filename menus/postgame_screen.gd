extends Control

func _ready() -> void:
	CharacterList.save_data()
	update_treasure()
	CharacterList.change_music(CharacterList.MUSIC_STATE.MENU)


func _on_menu_button_pressed() -> void:
	CharacterList.save_data()
	get_tree().change_scene_to_file("res://menus/scenes/menus/main_menu/main_menu_with_animations.tscn")


func _on_new_run_button_pressed() -> void:
	CharacterList.save_data()
	get_tree().change_scene_to_file("res://menus/pregame_screen.tscn")


func update_treasure():
	$Treasure/TreasureValue.text = str(CharacterList.total_treasure)
