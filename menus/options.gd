extends ItemList

signal option_tooltip(title: String, body: String)

func _ready() -> void:
	clear()
	

func _on_return_item_selected(index: int) -> void:
	clear()
	option_tooltip.emit("", "")
	var actor: PlayerActor = CharacterList.final_loadout[index]
	
	if actor is Soldier:
		add_item("[1] Solider Ability 1")
		add_item("[1] Solider Ability 2")
	elif actor is Archer:
		add_item("[1] Archer Ability")
		add_item("[2] Archer Spell")
	elif actor is Wizard:
		add_item("[2] Wizard Spell 1")
		add_item("[3] Wizard Spell 2")


func _on_item_selected(index: int) -> void:
	option_tooltip.emit(get_item_text(index), "BODY")
