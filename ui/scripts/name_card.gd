extends Container

class_name NameCard

@onready var bg_rect = $ColorRect
@onready var name_text = $MarginContainer/VFlowContainer/Name
@onready var hp_bar = $MarginContainer/VFlowContainer/HPBar
@onready var hp_text = $MarginContainer/VFlowContainer/HPValues
@onready var mp_bar = $MarginContainer/VFlowContainer/MPBar
@onready var mp_text = $MarginContainer/VFlowContainer/MPValues

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
