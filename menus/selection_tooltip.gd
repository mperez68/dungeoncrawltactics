extends VBoxContainer

@onready var title_text = $Title
@onready var body_panel = $PanelContainer/RichTextLabel
@onready var cost_text = $HBoxContainer/CostText


func _on_options_option_tooltip(title: String, body: String, cost: int) -> void:
	title_text.text = title
	body_panel.text = "[font_size=26]" + body + "[/font_size]"
	cost_text.text = str(cost)
	if cost > CharacterList.total_treasure:
		cost_text.self_modulate = Color.RED
	else:
		cost_text.self_modulate = Color.WHITE
	
