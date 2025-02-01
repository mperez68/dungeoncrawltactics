extends Button


func _on_loadout_lock_start_button(is_locked: int) -> void:
	disabled = is_locked
