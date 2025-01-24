extends AcceptDialog



func _on_confirmed() -> void:
	get_tree().change_scene_to_file("res://menus/scenes/menus/main_menu/main_menu_with_animations.tscn")
