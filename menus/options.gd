extends ItemList

signal option_tooltip(title: String, body: String, cost: int)
signal update_actor_panel(actor: MenuActor)
signal update_treasure

const UPGRADE_COST = 8

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
	add_item("Upgrade Health")
	add_item("Upgrade Mana")
	add_item("Upgrade Weapon")
	if actor.weapon_skill > 0.3:
		set_item_disabled(-1, true)
	add_item("Upgrade Armor")
	if actor.armor_skill > 0.3:
		set_item_disabled(-1, true)

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
	if index < all_items.size():
		var item = all_items[index]
		option_tooltip.emit(item.NAME, item.description, item.treasure_cost)
	else:
		match index - all_items.size():
			0:	# Health
				option_tooltip.emit("Inc. Health", "Increase maximum HP by 1.", UPGRADE_COST)
			1:	# Mana
				option_tooltip.emit("Inc. Mana", "Increase maximum MP by 1.", UPGRADE_COST)
			2:	# Weapon
				option_tooltip.emit("Upg. Weapon", "Increase weapon score by by 10.", UPGRADE_COST)
			3:	# Armor
				option_tooltip.emit("Upg. Armor", "Increase armor score by by 10.", UPGRADE_COST)


func _on_item_activated(index: int) -> void:
	var sz = all_items.size()
	
	if index < sz:
		if CharacterList.total_treasure < all_items[index].treasure_cost and CharacterList.final_loadout[actor_index].abilities.size() >= 5:
			# Can't afford / Item has no space in inventory
			return
		if all_items[index] is Ability:
			CharacterList.final_loadout[actor_index].abilities.push_back(all_items[index].duplicate())
		elif all_items[index] is Spell:
			CharacterList.final_loadout[actor_index].spell_book.push_back(all_items[index].duplicate())
		else:
			var item = all_items[index].duplicate()
			CharacterList.final_loadout[actor_index].inventory.push_back(item)
		CharacterList.total_treasure -= all_items[index].treasure_cost
		
		update_actor_panel.emit(CharacterList.get_menu_actor_from_player_actor(CharacterList.final_loadout[actor_index]))
	elif CharacterList.total_treasure >= UPGRADE_COST:
		match index - sz:
			0:	# Health
				CharacterList.final_loadout[actor_index].MAX_HEALTH += 1
			1:	# Mana
				CharacterList.final_loadout[actor_index].MAX_MANA += 1
			2:	# Weapon
				CharacterList.final_loadout[actor_index].weapon_skill += 0.1
			3:	# Armor
				CharacterList.final_loadout[actor_index].armor_skill += 0.1
	else:
		return
	_on_return_item_selected(actor_index)
	update_treasure.emit()
