extends AcceptDialog

var fail_state = false

func _on_confirmed() -> void:
	if fail_state:
		get_tree().change_scene_to_file("res://menus/pregame_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://menus/postgame_screen.tscn")
