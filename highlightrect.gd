extends Control

@onready var rect = $".."
var default

func _ready() -> void:
	default = rect.color

func _on_mouse_entered() -> void:
	rect.color = "0000ff80"


func _on_mouse_exited() -> void:
	rect.color = default
