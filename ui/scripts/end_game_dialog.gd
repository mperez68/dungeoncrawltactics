extends AcceptDialog



func _on_confirmed() -> void:
	get_tree().change_scene_to_file("res://menus/postgame_screen.tscn")
