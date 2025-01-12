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
const t = preload("res://ui/fading_text.tscn")
var rng = RandomNumberGenerator.new()
var index = -1


# constants
var MIN_HIT_CHANCE = 0.05
var BASE_HIT_CHANCE = 0.5
var MAX_HIT_CHANCE = 0.95
var BASE_CRIT_CHANCE = 0.05
var VANTAGE_BONUS = 0.2
var ZOOM_TIME = 0.5

# states
var active = false
var chance_text = null

# unique constants
@export var NAME = "Actor"
@export var WALK_RANGE = 6
@export var MAX_ACTIONS = 1
@export var MAX_HEALTH = 3
@export var MAX_MANA = 0
@export var is_sig: bool = false
@export var is_actor: bool = true
@export var corporeal: bool = true
# equipment values
@export var weapon_skill: float = 0.1
@export var armor_piercing: float = 0.0
@export var armor_skill: float = 0.1
@export var attack_range: int = 1
@export var melee_range: int = 1
@export var min_damage: int = 1
@export var max_damage: int = 3
@export var crit_multiplier: float = 1.5

# equipment
var inventory = []

# resources -- onready to get current export values
@onready var remaining_actions = MAX_ACTIONS
@onready var remaining_walk_range = WALK_RANGE
@onready var hp = MAX_HEALTH
@onready var mp = MAX_MANA

# UI
var select_type = SELECT_TYPE_NONE
var facing: String = "right"


# Engine
func _ready() -> void:
	# center on tile
	position = map.get_center(position)
	
	# Set solid in pathfinding
	if corporeal:
		map.set_position_solid(position)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.contains("shoot") or anim.animation.contains("swing") or anim.animation.contains("block"):
		anim.play("idle " + facing)


# Inputs
func _on_mouse_entered() -> void:
	# Break here if not the active actor or active actor return null
	var active_actor = manager.get_active()
	if !is_actor or active or !active_actor or hp <= 0:
		return
	# Highlight with hit chance if this actor is in range of the active actor
	hl.visible = true
	if chance_text == null and active_actor.remaining_actions > 0 and map.can_see(active_actor.position, position, active_actor.attack_range):
		chance_text = t.instantiate()
		chance_text.text = str(hit_chance(active_actor) * 100) + "%"
		chance_text.pending_animation = "hover"
		add_child(chance_text)

func _on_mouse_exited() -> void:
	hl.visible = false
	if chance_text != null:
		chance_text.queue_free()
		chance_text = null


# public methods
func start_turn():
	active = true
	anim_player.play("activate")
	# reset values
	remaining_walk_range = WALK_RANGE
	remaining_actions = MAX_ACTIONS
	# fix astar pathing
	map.set_position_solid(position, false)
	# UI
	center_screen()

func end_turn():
	if remaining_actions > 0:
		var pass_text = t.instantiate()
		pass_text.set_text("PASS")
		add_child(pass_text)
	active = false
	map.clear_highlights()
	map.set_position_solid(position)
	manager.pass_turn()
	
func is_exhausted() -> bool:
	var result = true
	if remaining_walk_range > 0:
		result = false
	if remaining_actions > 0:
		result = false
	return result

func center_screen(target: Vector2 = Vector2(-666, -666)):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(camera, "zoom", Vector2(camera.ZOOM_MAX, camera.ZOOM_MAX), ZOOM_TIME)
	var pos = position
	if target != Vector2(-666, -666):
		pos = (pos + target) / 2
	camera.position = pos

func attack(attacker: Actor):					## Attack vs. this player.
	var damage_text = t.instantiate()
	if rng.randf() < hit_chance(attacker):
		var damage: int
		var text_type = damage_text.TEXT_TYPE_NEGATIVE
		if rng.randf() < attacker.BASE_CRIT_CHANCE:
			damage = attacker.get_damage(true)
			text_type = damage_text.TEXT_TYPE_CRITICAL
			damage_text.scale = Vector2.ONE * attacker.crit_multiplier
		else:
			damage = attacker.get_damage()
		damage_text.set_text(str(damage), text_type)
		anim_player.play("damage")
		hp -= damage
	else:
		anim.play("block " + facing)
		damage_text.set_text("BLOCK", damage_text.TEXT_TYPE_BLOCK)
		anim_player.play("block")
	# Die if below 0 HP
	if hp <= 0:
		anim.play("die " + facing)
		map.set_position_solid(position, false)
	add_child(damage_text)

func hit_chance(attacker: Actor) -> float:		## Chance to hit this actor, given attacker node.
	# Armor Piercing only shreds armor, can't shred armor that isn't there ¯\_(ツ)_/¯
	var armor_total = max(armor_skill - attacker.armor_piercing, 0)
	var vantage = (int(map.is_vantage(attacker.position)) - int(map.is_vantage(position))) * VANTAGE_BONUS
	var cover = map.get_cover(attacker.position, position)
	return clamp(BASE_HIT_CHANCE + attacker.weapon_skill - armor_total + vantage - cover, MIN_HIT_CHANCE, MAX_HIT_CHANCE)

func get_damage(crit: bool = false) -> int:		## Retrieves a random damage value within this actors range.
	return rng.randi_range(min_damage, max_damage) * max(1, (int(crit) * crit_multiplier))

func select(new_type: int) -> bool:					## Change the selection type if active player.
	if select_type == new_type or !active:
		return false
	match new_type:
		SELECT_TYPE_WALK:
			if remaining_walk_range <= 0:
				return false
			map.draw_range(position, remaining_walk_range)
		SELECT_TYPE_ATTACK:
			if remaining_actions <= 0:
				return false
			map.draw_range(position, attack_range, false)
		SELECT_TYPE_NONE:
			if is_exhausted():
				end_turn()
			else:
				map.clear_highlights()
		_:
			return false
	select_type = new_type
	return true


# private methods
func _do_action_grid(map_coords: Vector2i) -> bool:
	return _do_action(map.ground_layer.map_to_local(map_coords))
	
func _do_action(map_coords: Vector2) -> bool:
	# Walk
	if select_type == SELECT_TYPE_WALK and map.can_walk(position, map_coords, remaining_walk_range):
		remaining_walk_range -= map.get_walk_distance(position, map_coords)
		_face(map_coords)
		anim.play("idle " + facing)
		position = map.get_center(map_coords)
		select(SELECT_TYPE_NONE)
		if remaining_walk_range > 0:
			select(SELECT_TYPE_WALK)
		# pickup non-actors
		if is_sig:
			var non = manager.remove_non_actors_at_position(map_coords)
			for a in non:
				inventory.push_back(true)
			
	
	# Attack
	elif select_type == SELECT_TYPE_ATTACK and map.can_see(position, map_coords, attack_range):
		# shoot if valid targets
		var targets = manager.get_actors_at_position(map_coords)
		# break if invalid attack targets
		if targets.is_empty() or targets.has(self):
			return false
		remaining_actions -= 1
		remaining_walk_range = 0
		_face(map_coords)
		# range or melee animation
		if attack_range > melee_range:
			anim.play("shoot " + facing)
		else:
			anim.play("swing " + facing)
		# Attack all targets
		for target in targets:
			if chance_text != null:
				chance_text.queue_free()
				chance_text = null
			target._face(position)
			target.attack(self)
		# Reset selection
		select(SELECT_TYPE_NONE)
	else:
		return false
	return true

func _face(target: Vector2):
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
