extends CenterContainer

class_name NameCard

var default
var hl_color = Color.BLACK
var dead_color = Color.DARK_RED
var dead_card = false
var actor: Actor

func _ready() -> void:
	default = $RectangleShape.color

func set_text(s: String):
	$Label.text = s

func highlight(active: bool = true):
	if dead_card:
		return
	if active:
		$RectangleShape.color = hl_color
	else:
		$RectangleShape.color = default

func die(dead: bool = true):
	if dead:
		$RectangleShape.color = dead_color
		dead_card = true
	else:
		$RectangleShape.color = default
		dead_card = false


func _on_mouse_entered() -> void:
	if actor:
		actor._on_mouse_entered()


func _on_mouse_exited() -> void:
	if actor:
		actor._on_mouse_exited()
