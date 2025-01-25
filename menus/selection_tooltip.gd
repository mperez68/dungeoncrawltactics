extends VBoxContainer

@onready var title_text = $Title
@onready var body_panel = $PanelContainer


func _on_options_option_tooltip(title: String, body: String) -> void:
	title_text.text = title
	print(title, "::", body)
