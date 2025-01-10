extends CenterContainer

class_name NameCard

@onready var bg_rect = $RectangleShape
@onready var name_text = $VFlowContainer/Name
@onready var hp_bar = $VFlowContainer/HPBar
@onready var hp_text = $VFlowContainer/HPValues
@onready var mp_bar = $VFlowContainer/MPBar
@onready var mp_text = $VFlowContainer/MPValues

var default
var hl_color = Color.BLACK
var dead_color = Color.DARK_RED
var select_color = Color("005d0054")
var dead_card = false
var actor: Actor

func _process(_delta: float) -> void:
	name_text.text = actor.NAME
	if actor and !dead_card:
		if actor.active:
			bg_rect.color = hl_color
		elif actor.hl.visible:
			bg_rect.color = select_color
		else:
			bg_rect.color = default
		
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
			hp_text.text = str(actor.MAX_HEALTH, " / ", actor.hp)
			if actor.MAX_MANA > 0:
				mp_bar.max_value = actor.MAX_MANA
				mp_bar.value = actor.mp
				mp_text.text = str(actor.MAX_MANA, " / ", actor.mp)
			elif mp_bar.visible or mp_text.visible:
				mp_text.visible = false
				mp_bar.visible = false

func _ready() -> void:
	default = bg_rect.color

func set_actor(a: Actor):
	if a:
		actor = a
	else:
		print("NULL ACTOR")


func _on_mouse_entered() -> void:
	if actor:
		actor._on_mouse_entered()


func _on_mouse_exited() -> void:
	if actor:
		actor._on_mouse_exited()
