extends Control

# References
@onready var rect = $".."

# Constants
@onready var COLOR_DEFAULT = rect.color
@onready var COLOR_HOVER = Color(COLOR_DEFAULT.r, COLOR_DEFAULT.g, COLOR_DEFAULT.b, min(COLOR_DEFAULT.a + 0.4, 1))
@export var OBJECTIVE = false
var TILE_SIZE: Vector2 = Vector2(16, 16)


# Engine
func _ready() -> void:
	# center on tile
	rect.global_position = global_position - (Vector2(roundi(global_position.x) % roundi(TILE_SIZE.x), roundi(global_position.y) % roundi(TILE_SIZE.y)))
	if OBJECTIVE:
		get_parent().get_parent().add_objective(global_position)

func _on_mouse_entered() -> void:
	rect.color = COLOR_HOVER

func _on_mouse_exited() -> void:
	rect.color = COLOR_DEFAULT
