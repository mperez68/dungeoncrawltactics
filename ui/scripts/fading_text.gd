extends Node2D

enum{ TEXT_TYPE_DEFAULT, TEXT_TYPE_BLOCK, TEXT_TYPE_POSITIVE, TEXT_TYPE_NEGATIVE, TEXT_TYPE_CRITICAL }

@onready var label = $Control/Label
@onready var anim = $AnimationPlayer

var text: String
var color: Color
var pending_animation: String = ""

func _ready() -> void:
	label.text = text
	label.label_settings.font_color = color
	if !pending_animation.is_empty():
		anim.play(pending_animation)

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
		TEXT_TYPE_CRITICAL:
			color = Color.RED
		-1:
			pass

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
