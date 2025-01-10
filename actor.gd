extends CharacterBody2D

class_name Actor

enum{ SELECT_TYPE_NONE, SELECT_TYPE_WALK, SELECT_TYPE_ATTACK }

# reference
@onready var map = $"../Map"
@onready var camera = $"../Camera"
@onready var manager = get_parent()
@onready var hl = $HighlightBox
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
var index = -1

const t = preload("res://ui/fading_text.tscn")
var rng = RandomNumberGenerator.new()

# constants
var BASE_HIT_CHANCE = 0.5
var MAX_HIT_CHANCE = 0.95
var VANTAGE_BONUS = 0.2
var ZOOM_TIME = 0.5
# unique constants
@export var NAME = "Actor"
@export var WALK_RANGE = 6
@export var MAX_ACTIONS = 1
@export var MAX_HEALTH = 3
@export var MAX_MANA = 0

# states
var active = false
var chance_text = null

# equipment values
var weapon_skill: float = 0.0
var armor_piercing: float = 0.0
var armor_skill: float = 0.0
var attack_range: int = 10
var melee_range: int = 1
var min_damage: int = 1
var max_damage: int = 3

# resources -- onready to get current export values
@onready var remaining_actions = MAX_ACTIONS
@onready var remaining_walk_range = WALK_RANGE
@onready var hp = MAX_HEALTH
@onready var mp = MAX_MANA

# UI
var select_type = SELECT_TYPE_NONE
var facing: String = "right"


func _ready() -> void:
	# center on tile
	position = map.get_center(position)
	map.set_position_solid(position)

func _input(event: InputEvent) -> void:
	# No actions can be done while not active actor
	if !active:
		return
	
	# Mouse events
	if event is InputEventMouse:
		var map_coords = ((event.position - (camera.get_viewport_rect().end / 2))/ camera.zoom) + camera.position
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			do_action(map_coords)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var temp = select_type
			select(SELECT_TYPE_ATTACK)
			do_action(map_coords)
			select(temp)


func start_turn():
	active = true
	anim_player.play("activate")
	remaining_walk_range = WALK_RANGE
	remaining_actions = MAX_ACTIONS
	map.set_position_solid(position, false)
	select(SELECT_TYPE_WALK)
	# center camera on actor if not in center of screen
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(camera, "zoom", Vector2(camera.ZOOM_MAX, camera.ZOOM_MAX), ZOOM_TIME)
	camera.position = position

func end_turn():
	active = false
	map.clear_highlights()
	manager.pass_turn()
	map.set_position_solid(position)


func do_action(map_coords):
	# Walk
	if select_type == SELECT_TYPE_WALK and map.can_walk(position, map_coords, remaining_walk_range):
		remaining_walk_range -= map.get_walk_distance(position, map_coords)
		face(map_coords)
		anim.play("idle " + facing)
		position = map.get_center(map_coords)
		select(SELECT_TYPE_NONE)
	
	# Attack
	if select_type == SELECT_TYPE_ATTACK and map.can_see(position, map_coords, attack_range):
		# shoot if valid targets
		var targets = manager.get_actors_at_position(map_coords)
		# break if invalid attack
		if targets.is_empty() or targets.has(self):
			return
		remaining_actions -= 1
		remaining_walk_range = 0
		face(map_coords)
		if attack_range > melee_range:
			anim.play("shoot " + facing)
		else:
			anim.play("swing " + facing)
		for target in targets:
			var vantage = 0
			if map.is_vantage(position) and !map.is_vantage(target.position):
				vantage = VANTAGE_BONUS
				var new_text = t.instantiate()
				new_text.set_text("vantage")
				add_child(new_text)
				if chance_text != null:
					chance_text.queue_free()
					chance_text = null
			target.face(position)
			target.attack(rng.randi_range(min_damage, max_damage), weapon_skill + vantage)
		select(SELECT_TYPE_NONE)


func is_exhausted() -> bool:
	var result = true
	if remaining_walk_range > 0:
		result = false
	if remaining_actions > 0:
		result = false
	return result

func select(new_type: int):
	if select_type == new_type and select_type != SELECT_TYPE_NONE:
		select(SELECT_TYPE_NONE)
		return
	match new_type:
		SELECT_TYPE_WALK:
			if remaining_walk_range <= 0:
				return
			map.draw_range(position, remaining_walk_range)
		SELECT_TYPE_ATTACK:
			if remaining_actions <= 0:
				return
			map.draw_range(position, attack_range, false)
		SELECT_TYPE_NONE:
			if is_exhausted():
				end_turn()
			else:
				map.clear_highlights()
		_:
			select(SELECT_TYPE_NONE)
	select_type = new_type

func hit_chance(ws: float = 0, ap: float = 0, crit: float = 0.1, crit_mult: float = 1.5) -> float:
	return min(BASE_HIT_CHANCE + armor_skill - ap, MAX_HIT_CHANCE) - ws


func attack(val: int, ws: float = 0, ap: float = 0, crit: float = 0.1, crit_mult: float = 1.5):
	var new_text = t.instantiate()
	if rng.randf() + ws > min(BASE_HIT_CHANCE + armor_skill - ap, MAX_HIT_CHANCE):
		if rng.randf() < crit:
			hp -= round(val * crit_mult)
			anim_player.play("damage")
			new_text.set_text(String.num(round(val * crit_mult)) + "!", new_text.TEXT_TYPE_CRITICAL)
			new_text.scale = Vector2(crit_mult, crit_mult)
		else:
			hp -= val
			anim_player.play("damage")
			new_text.set_text(String.num(val), new_text.TEXT_TYPE_NEGATIVE)
	else:
		anim.play("block " + facing)
		new_text.set_text("BLOCK", new_text.TEXT_TYPE_BLOCK)
	if hp <= 0:
		anim.play("die " + facing)
		map.set_position_solid(position, false)
	add_child(new_text)


func _on_mouse_entered() -> void:
	if active:
		return
	# Highlight
	hl.visible = true
	var active_actor = manager.get_active()
	if chance_text == null and active_actor and active_actor.remaining_actions > 0 and map.can_see(active_actor.position, position, active_actor.attack_range):
		chance_text = t.instantiate()
		var vantage = 0
		if map.is_vantage(active_actor.position) and !map.is_vantage(position):
			vantage = VANTAGE_BONUS
		chance_text.text = "% " + str((active_actor.hit_chance() + vantage) * 100)
		chance_text.pending_animation = "hover"
		add_child(chance_text)

func _on_mouse_exited() -> void:
	hl.visible = false
	if chance_text != null:
		chance_text.queue_free()
		chance_text = null


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.contains("shoot") or anim.animation.contains("swing") or anim.animation.contains("block"):
		anim.play("idle " + facing)

func face(target: Vector2):
	var dif = map.local_to_map(position) - map.local_to_map(target)
	if abs(dif.x) >= abs(dif.y):
		if dif.x > 0:
			facing = "left"
		else:
			facing = "right"
	else:
		if dif.y > 0:
			facing = "up"
		else:
			facing = "down"
