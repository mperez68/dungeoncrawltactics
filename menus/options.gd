extends ItemList

signal option_tooltip(title: String, body: String, cost: int)
signal update_actor_panel(actor: MenuActor)

var all_items: Array[Node] = []
var actor_index = 0

func _ready() -> void:
	clear()
	all_items.clear()


func _on_return_item_selected(index: int) -> void:
	clear()
	all_items.clear()
	option_tooltip.emit("", "", 0)
	var actor: PlayerActor = CharacterList.final_loadout[index]
	actor_index = index
	
	for item in CharacterList.generic_options:
		add_item(item.NAME)
		all_items.push_back(item)
	if actor is Soldier:
		for item in CharacterList.soldier_options:
			if !has(actor, item.NAME):
				add_item(item.NAME)
				all_items.push_back(item)
	elif actor is Archer:
		for item in CharacterList.archer_options:
			if !has(actor, item.NAME):
				add_item(item.NAME)
				all_items.push_back(item)
	elif actor is Wizard:
		for item in CharacterList.wizard_options:
			if !has(actor, item.NAME):
				add_item(item.NAME)
				all_items.push_back(item)

func has(actor: PlayerActor, item_in: String) -> bool:
	var ret = false
	for item in actor.abilities:
		if item.NAME == item_in:
			ret = true
	for item in actor.spell_book:
		if item.NAME == item_in:
			ret = true
	return ret

func _on_item_selected(index: int) -> void:
	var item = all_items[index]
	option_tooltip.emit(item.NAME, item.description, item.treasure_cost)


func _on_item_activated(index: int) -> void:
	if all_items[index] is Ability:
		CharacterList.final_loadout[actor_index].abilities.push_back(all_items[index].duplicate())
	elif all_items[index] is Spell:
		CharacterList.final_loadout[actor_index].spell_book.push_back(all_items[index].duplicate())
	else:
		CharacterList.final_loadout[actor_index].inventory.push_back(all_items[index].duplicate())
	CharacterList.total_treasure -= all_items[index].treasure_cost
	
	update_actor_panel.emit(CharacterList.get_menu_actor_from_player_actor(CharacterList.final_loadout[actor_index]))
	_on_return_item_selected(actor_index)
