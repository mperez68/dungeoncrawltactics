extends CenterContainer

class_name NameCard

@onready var bg_rect = $RectangleShape
@onready var name_text = $VFlowContainer/Name
@onready var hp_bar = $VFlowContainer/HPBar
@onready var mp_bar = $VFlowContainer/MPBar

var default
var hl_color = Color.BLACK
var dead_color = Color.DARK_RED
var dead_card = false
var actor: Actor

func _process(_delta: float) -> void:
	name_text.text = actor.NAME
	if actor and !dead_card:
		if actor.active:
			bg_rect.color = hl_color
		else:
			bg_rect.color = default
		
		if actor.hp <= 0:
			bg_rect.color = dead_color
			hp_bar.visible = false
			mp_bar.visible = false
			dead_card = true
		else:
			hp_bar.value = actor.hp
			if actor.MAX_MANA > 0:
				mp_bar.value = actor.mp
			elif mp_bar.visible:
				mp_bar.visible = false

func _ready() -> void:
	default = bg_rect.color

func set_actor(a: Actor):
	if a:
		actor = a
	else:
		print("NULL ACTOR")

func highlight(active: bool = true):
	pass
	#if dead_card:
		#return
	#if active:
		#bg_rect.color = hl_color
	#else:
		#bg_rect.color = default

func die(dead: bool = true):
	pass
	#if dead:
		#bg_rect.color = dead_color
		#dead_card = true
	#else:
		#bg_rect.color = default
		#dead_card = false


func _on_mouse_entered() -> void:
	if actor:
		actor._on_mouse_entered()


func _on_mouse_exited() -> void:
	if actor:
		actor._on_mouse_exited()
