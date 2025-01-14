extends CanvasLayer

class_name HUD

signal button_pressed(select_type: int)
signal spell_pressed(spell: int)
signal ability_pressed(ability: int)
signal inventory_pressed(item: int)
signal end_turn

var name_card = preload("res://ui/name_card.tscn")

# reference
@onready var map = $"../Map"
@onready var camera = $"../Camera"
@onready var counter = $TurnTracker/TurnCountCard/VFlowContainer/TurnCount
# child references
@onready var tracker = $TurnTracker
@onready var all_buttons = $ActionBar.get_children()
@onready var spell_buttons = find_children("*Spell*")
@onready var ability_buttons = find_children("*Ability*")
@onready var inventory_buttons = find_children("*Inventory*")
# debug references
@onready var debug_ui = $DebugUI
@onready var location_text = $DebugUI/CursorLocation
@onready var vantage_text = $DebugUI/CursorVantage

# values
@export var debug = false
@onready var BUTTON_DEFAULT_COLOR = all_buttons[0].self_modulate
const BUTTON_DISABLE_COLOR = Color(0.227, 0.227, 0.227, 0.498)


# Engine
func _ready():
	if debug:
		debug_ui.visible = true
	visible = true

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


# Private Methods
func _on_level_inc_turn_counter(turn: int) -> void:
	counter.text = str(turn)


# Signals
func _on_node_new_turn_order(actors: Array[Actor]) -> void:
	# clear list
	for card in tracker.get_children().slice(1):
		card.queue_free()
	for actor in actors:
		var card = name_card.instantiate()
		card.set_actor(actor)
		tracker.add_child(card)

func _on_level_enable_ui(enable: bool) -> void:
	var color = BUTTON_DEFAULT_COLOR
	if !enable:
		color = BUTTON_DISABLE_COLOR
	for button in all_buttons:
		button.disabled = !enable
		button.self_modulate = color

func _on_pressed(select_type: int) -> void:
	button_pressed.emit(select_type)

func _end_turn_pressed() -> void:
	end_turn.emit()

func _on_spell_pressed(spell_index: int) -> void:
	spell_pressed.emit(spell_index)
