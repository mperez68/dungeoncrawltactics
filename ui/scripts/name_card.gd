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
var hl_color = Color.BLACK
var dead_color = Color(0.545, 0, 0, 0.588)
var select_color = Color(0, 0.564, 0, 0.435)
var dead_card = false
var actor: Actor

func _process(_delta: float) -> void:
	if actor and !dead_card:
		name_text.text = actor.NAME
		if actor.active:
			bg_rect.color = hl_color
			for i in actor.spell_book.size():
				if actor.spell_book[i].mana_cost > actor.mp and hud.spell_buttons[i].disabled == false:
					hud.spell_buttons[i].disabled = true
				else:
					hud.spell_buttons[i].disabled = false
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
	for i in actor.spell_book.size():
		hud.spell_buttons[i].visible = is_active
		if is_active:
			hud.spell_buttons[i].texture_normal = actor.spell_book[i].texture_normal
			hud.spell_buttons[i].texture_pressed = actor.spell_book[i].texture_pressed
			hud.spell_buttons[i].texture_hover = actor.spell_book[i].texture_hover
			hud.spell_buttons[i].texture_disabled = actor.spell_book[i].texture_disabled
			hud.spell_buttons[i].texture_focused = actor.spell_book[i].texture_focused
			hud.spell_buttons[i].texture_click_mask = actor.spell_book[i].texture_click_mask
			

func set_actor(a: Actor):
	if a:
		actor = a
		a.update_hud.connect(update_hud)
	else:
		print("NULL ACTOR")


func _on_mouse_entered() -> void:
	if actor:
		actor._on_mouse_entered()


func _on_mouse_exited() -> void:
	if actor:
		actor._on_mouse_exited()
