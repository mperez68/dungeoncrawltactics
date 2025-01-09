extends CanvasLayer

signal button_pressed(select_type: int)
signal end_turn

@onready var cursor_text = $CenterContainer/CursorLocation
@onready var map = $"../Map"
@onready var camera = $"../Camera"

func _ready():
	visible = true

func _on_pressed(select_type: int) -> void:
	button_pressed.emit(select_type)


func _end_turn_pressed() -> void:
	end_turn.emit()

func _input(event: InputEvent) -> void:
	# Mouse events
	if event is InputEventMouse:
		var map_coords = map.local_to_map(((event.position - (camera.get_viewport_rect().end / 2))/ camera.zoom) + camera.position)
		cursor_text.text = str(map_coords)
