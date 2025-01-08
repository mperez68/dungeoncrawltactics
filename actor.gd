extends CharacterBody2D

class_name Actor

enum{ SELECT_TYPE_NONE, SELECT_TYPE_WALK, SELECT_TYPE_ATTACK }

@onready var map = $"../Map"
@onready var camera = $"../Camera"
@onready var manager = get_parent()
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer

const t = preload("res://fading_text.tscn")
var rng = RandomNumberGenerator.new()

var WALK_RANGE = 6
var ATTACK_RANGE = 1
var MAX_ACTIONS = 1
var MAX_HIT_CHANCE = 0.95

var remaining_actions = MAX_ACTIONS
var remaining_walk_range = WALK_RANGE
var weapon_skill: float = 0.0
var armor_skill: float = 0.0
var active = false
var hp = 5
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
	if event is InputEventMouse and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var map_coords = ((event.position - (camera.get_viewport_rect().end / 2))/ camera.zoom) + camera.position
		do_action(map_coords)


func start_turn():
	active = true
	$ActiveCircle.visible = true
	remaining_walk_range = WALK_RANGE
	remaining_actions = MAX_ACTIONS
	map.set_position_solid(position, false)
	select(SELECT_TYPE_WALK)
	# center camera on actor if not in center of screen
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(camera, "zoom", Vector2(2, 2), 1)
	if abs(position - camera.position).length() > (min(camera.get_viewport_rect().end.y / 2, camera.get_viewport_rect().end.x / 2)) / 2:
		camera.position = position

func end_turn():
	active = false
	$ActiveCircle.visible = false
	map.clear_highlights()
	$"..".pass_turn()
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
	if select_type == SELECT_TYPE_ATTACK and map.can_see(position, map_coords, ATTACK_RANGE):
		# shoot if valid targets
		var targets = manager.get_actors_at_position(map_coords)
		# break if invalid attack
		if targets.is_empty() or targets.has(self):
			return
		remaining_actions -= 1
		remaining_walk_range = 0
		face(map_coords)
		if ATTACK_RANGE > 1:
			anim.play("shoot " + facing)
		else:
			anim.play("swing " + facing)
		for target in targets:
			var vantage_bonus = 0
			if map.is_vantage(position) and !map.is_vantage(target.position):
				vantage_bonus = 0.2
				var new_text = t.instantiate()
				new_text.set_text("vantage")
				add_child(new_text)
			target.face(position)
			target.attack(rng.randi_range(1, 3), weapon_skill + vantage_bonus)
		select(SELECT_TYPE_NONE)


func is_exhausted() -> bool:
	var result = true
	if remaining_walk_range > 0:
		result = false
	if remaining_actions > 0:
		result = false
	return result

func select(new_type: int):
	if select_type == new_type:
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
			map.draw_range(position, ATTACK_RANGE, false)
		SELECT_TYPE_NONE:
			if is_exhausted():
				end_turn()
			else:
				map.clear_highlights()
		_:
			select(SELECT_TYPE_NONE)
	select_type = new_type

func attack(val: int, ws: float = 0, ap: float = 0):
	
	var new_text = t.instantiate()
	if rng.randf() + ws > min(0.5 + armor_skill - ap, MAX_HIT_CHANCE):
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
	$HighlightBox.visible = true

func _on_mouse_exited() -> void:
	$HighlightBox.visible = false


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
