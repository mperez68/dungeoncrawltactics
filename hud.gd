extends CanvasLayer

signal button_pressed(select_type: int)
signal end_turn

func _ready():
	visible = true

func _on_pressed(select_type: int) -> void:
	button_pressed.emit(select_type)


func _end_turn_pressed() -> void:
	end_turn.emit()
