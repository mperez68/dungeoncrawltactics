extends Container

class_name NameCard

@onready var bg_rect = $ColorRect
@onready var name_text = $MarginContainer/VFlowContainer/Name
@onready var hp_bar = $MarginContainer/VFlowContainer/HPBar
@onready var hp_text = $MarginContainer/VFlowContainer/HPValues
@onready var mp_bar = $MarginContainer/VFlowContainer/MPBar
@onready var mp_text = $MarginContainer/VFlowContainer/MPValues
@onready var hud: HUD = get_parent().get_parent()

var default
var hl_color = Color(0, 0, 1, 0.435)
var dead_color = Color(0.545, 0, 0, 0.588)
var select_color = Color(0, 0.564, 0, 0.435)
var dead_card = false
var actor: Actor

func _process(_delta: float) -> void:
	if actor and !dead_card:
		name_text.text = actor.NAME
		if actor.active:
			bg_rect.color = hl_color
			# Populate spells
			for i in hud.spell_buttons.size():
				if i < actor.spell_book.size() and (actor.spell_book[i].mana_cost > actor.mp or actor.remaining_actions <= 0) and hud.spell_buttons[i].disabled == false:
					hud.spell_buttons[i].disabled = true
					hud.spell_buttons[i].focus_mode = Button.FOCUS_NONE
				elif i < actor.spell_book.size() and actor.spell_book[i].mana_cost <= actor.mp and actor.remaining_actions > 0:
					hud.spell_buttons[i].disabled = false
					hud.spell_buttons[i].focus_mode = Button.FOCUS_CLICK
				elif i >= actor.spell_book.size():
					hud.spell_buttons[i].visible = false
			# Populate abilities
			for i in hud.ability_buttons.size():
				if i < actor.abilities.size() and hud.ability_buttons[i].disabled == false and (actor.remaining_actions <= 0 or actor.abilities[i].remaining_cooldown > 0):
					hud.ability_buttons[i].visible = true
					hud.ability_buttons[i].disabled = true
					hud.ability_buttons[i].focus_mode = Button.FOCUS_NONE
				elif i < actor.abilities.size() and actor.remaining_actions > 0 and actor.abilities[i].remaining_cooldown <= 0:
					hud.ability_buttons[i].visible = true
					hud.ability_buttons[i].disabled = false
					hud.ability_buttons[i].focus_mode = Button.FOCUS_CLICK
				elif i >= actor.abilities.size():
					hud.ability_buttons[i].visible = false
			# Populate Equipment
			for i in hud.inventory_buttons.size():
				if i < actor.inventory.size() and hud.inventory_buttons[i].disabled == false and (actor.remaining_actions <= 0 or actor.inventory[i].count <= 0):
					hud.inventory_buttons[i].visible = true
					hud.inventory_buttons[i].disabled = true
					hud.inventory_buttons[i].focus_mode = Button.FOCUS_NONE
				elif i < actor.inventory.size() and actor.remaining_actions > 0 and actor.inventory[i].count > 0:
					hud.inventory_buttons[i].visible = true
					hud.inventory_buttons[i].disabled = false
					hud.inventory_buttons[i].focus_mode = Button.FOCUS_CLICK
				elif i >= actor.inventory.size():
					hud.inventory_buttons[i].visible = false
			
		elif actor.hl.visible:
			bg_rect.color = select_color
		else:
			bg_rect.color = default
			
		visible = actor.visible
			
		if actor.hp <= 0:
			bg_rect.color = dead_color
			hp_text.visible = false
			hp_bar.visible = false
			mp_text.visible = false
			mp_bar.visible = false
			dead_card = true
		else:
			hp_bar.max_value = actor.MAX_HEALTH
			hp_bar.value = actor.hp
			hp_text.text = str(actor.hp, " / ", actor.MAX_HEALTH)
			if actor.MAX_MANA > 0:
				mp_bar.max_value = actor.MAX_MANA
				mp_bar.value = actor.mp
				mp_text.text = str(actor.mp, " / ", actor.MAX_MANA)
			elif mp_bar.visible or mp_text.visible:
				mp_text.visible = false
				mp_bar.visible = false

func _ready() -> void:
	default = bg_rect.color

func update_hud(is_active: bool):
	# Update HUD
	if !actor.is_sig:
		return
	# Spells
	for i in actor.spell_book.size():
		if is_active:
			hud.spell_buttons[i].visible = is_active
			hud.spell_buttons[i].texture_normal = actor.spell_book[i].texture_normal
			hud.spell_buttons[i].texture_pressed = actor.spell_book[i].texture_pressed
			hud.spell_buttons[i].texture_hover = actor.spell_book[i].texture_hover
			hud.spell_buttons[i].texture_disabled = actor.spell_book[i].texture_disabled
			hud.spell_buttons[i].texture_focused = actor.spell_book[i].texture_focused
			hud.spell_buttons[i].texture_click_mask = actor.spell_book[i].texture_click_mask
	# Abilities
	for i in actor.abilities.size():
		if is_active:
			hud.ability_buttons[i].visible = is_active
			hud.ability_buttons[i].texture_normal = actor.abilities[i].texture_normal
			hud.ability_buttons[i].texture_pressed = actor.abilities[i].texture_pressed
			hud.ability_buttons[i].texture_hover = actor.abilities[i].texture_hover
			hud.ability_buttons[i].texture_disabled = actor.abilities[i].texture_disabled
			hud.ability_buttons[i].texture_focused = actor.abilities[i].texture_focused
			hud.ability_buttons[i].texture_click_mask = actor.abilities[i].texture_click_mask
	# Equipment
	for i in actor.inventory.size():
		if is_active:
			hud .inventory_buttons[i].visible = is_active
			hud.inventory_buttons[i].texture_normal = actor.inventory[i].texture_normal
			hud.inventory_buttons[i].texture_pressed = actor.inventory[i].texture_pressed
			hud.inventory_buttons[i].texture_hover = actor.inventory[i].texture_hover
			hud.inventory_buttons[i].texture_disabled = actor.inventory[i].texture_disabled
			hud.inventory_buttons[i].texture_focused = actor.inventory[i].texture_focused
			hud.inventory_buttons[i].texture_click_mask = actor.inventory[i].texture_click_mask
	# Embark
	if actor.can_embark:
		hud.embark_button.disabled = false
		hud.embark_button.focus_mode = Button.FOCUS_CLICK
	else:
		hud.embark_button.disabled = true
		hud.embark_button.focus_mode = Button.FOCUS_NONE
	# Movement
	if actor.remaining_walk_range > 0:
		hud.walk_button.disabled = false
		hud.walk_button.focus_mode = Button.FOCUS_CLICK
	else:
		hud.walk_button.disabled = true
		hud.walk_button.focus_mode = Button.FOCUS_NONE
	# Set focus
	match actor.select_type:
		Actor.SELECT_TYPE_ATTACK:
			hud.attack_button.grab_focus()

func set_actor(a: Actor):
	if a:
		actor = a
		a.update_hud.connect(update_hud)
		a.remove_card.connect(queue_free)
	else:
		print("NULL ACTOR")


func _on_mouse_entered() -> void:
	if actor:
		actor._on_mouse_entered()


func _on_mouse_exited() -> void:
	if actor:
		actor._on_mouse_exited()
