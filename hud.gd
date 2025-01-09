extends CanvasLayer

signal button_pressed(select_type: int)
signal end_turn

@onready var location_text = $CenterContainer/CursorLocation
@onready var vantage_text = $CenterContainer/CursorVantage
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
		var local_coords = ((event.position - (camera.get_viewport_rect().end / 2))/ camera.zoom) + camera.position
		var map_coords = map.local_to_map(local_coords)
		location_text.text = str(map_coords)
		if map.is_vantage(local_coords):
			vantage_text.text = "VANTAGE"
		elif !map.can_stand(local_coords):
			vantage_text.text = "SOLID"
		else:
			vantage_text.text = ""
