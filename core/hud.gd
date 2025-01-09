extends CanvasLayer

signal button_pressed(select_type: int)
signal end_turn

var name_card = preload("res://ui/name_card.tscn")

@onready var location_text = $CenterContainer/CursorLocation
@onready var vantage_text = $CenterContainer/CursorVantage
@onready var map = $"../Map"
@onready var camera = $"../Camera"
@onready var tracker = $TurnTracker

var debug = true
var turn_order = []

func _ready():
	if debug:
		$CenterContainer.visible = true
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


func _on_node_new_turn_order(actors: Array[Actor]) -> void:
	# clear list
	for card in tracker.get_children():
		card.queue_free()
		turn_order.clear()
	for actor in actors:
		var card = name_card.instantiate()
		card.set_text(actor.NAME)
		card.actor = actor
		tracker.add_child(card)
		turn_order.push_back(card)


func _on_node_next_turn(index: int) -> void:
	if index < turn_order.size():
		for i in turn_order.size():
			if i == index:
				turn_order[i].highlight()
			else:
				turn_order[i].highlight(false)
				


func _on_node_remove_from_tracker(index: int) -> void:
	if index < turn_order.size():
		turn_order[index].die()
