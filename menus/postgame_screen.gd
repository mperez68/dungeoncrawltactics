extends Control


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/scenes/menus/main_menu/main_menu_with_animations.tscn")


func _on_new_run_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/pregame_screen.tscn")
