extends Node2D

enum{ TEXT_TYPE_DEFAULT, TEXT_TYPE_BLOCK, TEXT_TYPE_POSITIVE, TEXT_TYPE_NEGATIVE }

@onready var label = $Control/Label

var text: String
var color: Color

func _ready() -> void:
	label.text = text
	label.label_settings.font_color = color

func set_text(val: String, type_in: int = -1):
	text = val
	
	match type_in:
		TEXT_TYPE_DEFAULT:
			color = Color.BLACK
		TEXT_TYPE_BLOCK:
			color = Color.DARK_BLUE
		TEXT_TYPE_POSITIVE:
			color = Color.DARK_GREEN
		TEXT_TYPE_NEGATIVE:
			color = Color.DARK_RED
		-1:
			pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
