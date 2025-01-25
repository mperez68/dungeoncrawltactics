extends VBoxContainer

@onready var actor_name = $Name
@onready var actor_class = $Class
@onready var ability_list = $AbilityList
@onready var spell_list = $SpellList

func _ready() -> void:
	actor_name.text = "[font_size=26]-[/font_size]"
	actor_class.text = "[font_size=22]-[/font_size]"


func _on_return_item_selected(index: int) -> void:
	var actor = CharacterList.get_menu_actor(index)
	actor_name.text = "[font_size=26][u]" + actor.actor_name + "[/u][/font_size]"
	actor_class.text = "[font_size=22]" + actor.actor_class + "[/font_size]"
