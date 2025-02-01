extends VBoxContainer

@onready var actor_name = $Name
@onready var actor_class = $Class
@onready var ability_list_container = $AbilityList
@onready var spell_list_container = $SpellList
@onready var inventory_list_container = $ItemsList
@onready var hp_text = $Stats/HPBox/text
@onready var mp_text = $Stats/MPBox/text
@onready var ws_text = $Stats/WeapBox/text
@onready var as_text = $Stats/ArmorBox/text

const DEFAULT = preload("res://png/spells/spell_tile.png")

var ability_list = []
var spell_list = []
var inventory_list = []

func _ready() -> void:
	actor_name.text = "[font_size=26]-[/font_size]"
	actor_class.text = "[font_size=22]-[/font_size]"
	ability_list = ability_list_container.get_children()
	spell_list = spell_list_container.get_children()
	inventory_list = inventory_list_container.get_children()
	clear()


func clear():
	for ability in ability_list:
		ability.texture = DEFAULT
		ability.tooltip_text = ""
	for spell in spell_list:
		spell.texture = DEFAULT
		spell.tooltip_text = ""
	for item in inventory_list:
		item.texture = DEFAULT
		item.tooltip_text = ""


func _on_update_selected_actor(actor: MenuActor) -> void:
	actor_name.text = "[font_size=26][u]" + actor.actor_name + "[/u][/font_size]"
	actor_class.text = "[font_size=22]" + actor.actor_class + "[/font_size]"
	
	clear()
	
	for i in actor.abilities.size():
		var ability: Ability = actor.abilities[i]
		ability_list[i].texture = ability.texture_normal
		ability_list[i].tooltip_text = ability.NAME
	for i in actor.spells.size():
		var spell: Spell = actor.spells[i]
		spell_list[i].texture = spell.texture_normal
		spell_list[i].tooltip_text = spell.NAME
	for i in actor.inventory.size():
		var item: EquipmentActor = actor.inventory[i]
		inventory_list[i].texture = item.texture_normal
		inventory_list[i].tooltip_text = item.NAME
	
	hp_text.text = str("[center]", actor.actor_reference.MAX_HEALTH)
	mp_text.text = str("[center]", actor.actor_reference.MAX_MANA)
	ws_text.text = str("[center]", actor.actor_reference.weapon_skill * 100)
	as_text.text = str("[center]", actor.actor_reference.armor_skill * 100)
