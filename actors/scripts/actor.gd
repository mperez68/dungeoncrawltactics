extends CharacterBody2D

class_name Actor

enum{ SELECT_TYPE_NONE, SELECT_TYPE_WALK, SELECT_TYPE_ATTACK, SELECT_TYPE_SPELL, SELECT_TYPE_ABILITY, SELECT_TYPE_INVENTORY }

signal update_hud(is_active: bool)

# reference
@onready var map = $"../Map"
@onready var camera = $"../Camera"
@onready var manager = get_parent()
@onready var hl = $HighlightBox
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var input_timer = $InputTimer
@onready var action_timer = $ActionTimer
const t = preload("res://ui/fading_text.tscn")
var rng = RandomNumberGenerator.new()
var index = -1


# constants
const MIN_HIT_CHANCE = 0.05
const BASE_HIT_CHANCE = 0.5
const MAX_HIT_CHANCE = 0.95
const BASE_CRIT_CHANCE = 0.05
const VANTAGE_BONUS = 0.2
const ZOOM_TIME = 0.5

# states
var active = false
var chance_text = null
var debug = false

# unique constants
@export var NAME = "Actor"
@export var SIGHT_RANGE = 10
@export var WALK_RANGE = 8
@export var MAX_ACTIONS = 1
@export var MAX_HEALTH = 3
@export var MAX_MANA = 0
@export var is_sig: bool = false
@export var is_actor: bool = true
@export var corporeal: bool = true
# equipment values
@export var weapon_skill: float = 0
@export var spell_skill: float = 0
@export var armor_piercing: float = 0.0
@export var spell_piercing: float = 0.0
@export var armor_skill: float = 0
@export var magic_resist: float = 0
@export var attack_range: int = 1
@export var melee_range: int = 1
@export var min_damage: int = 1
@export var max_damage: int = 3
@export var crit_modifier: float = 0
@export var crit_multiplier: float = 1.5

# equipment
var spell_book: Array[Spell] = []
var spell_pointer: int = -1
var abilities: Array[Ability] = [ preload("res://actions/dash.tscn").instantiate() ]
var ability_pointer: int = -1
var inventory = []
var inventory_pointer: int = -1

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
	
	if is_sig:
		_clear_fog(position, SIGHT_RANGE)
	elif map.is_in_fog(position):
		visible = false
	
	# Set solid in pathfinding
	if corporeal:
		map.set_position_solid(position)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.contains("shoot") or anim.animation.contains("swing") or anim.animation.contains("block"):
		anim.play("idle " + facing)


# Inputs
func _on_mouse_entered() -> void:
	# Break here if not the active actor or active actor return null
	var active_actor: Actor = manager.get_active()
	if !is_actor or !active_actor or hp <= 0:
		return
	# Highlight with hit chance if this actor is in range of the active actor
	hl.visible = true
	var targetting_range = active_actor.attack_range
	if active_actor.select_type == Actor.SELECT_TYPE_SPELL:
		targetting_range = active_actor.spell_book[active_actor.spell_pointer].attack_range
	if !is_sig and chance_text == null and active_actor.remaining_actions > 0 and map.can_see(active_actor.position, position, targetting_range):
		chance_text = t.instantiate()
		var targetting_chance = hit_chance(active_actor)
		if active_actor.select_type == Actor.SELECT_TYPE_SPELL:
			targetting_chance = active_actor.spell_book[active_actor.spell_pointer].hit_chance(active_actor, self)
		chance_text.text = str(targetting_chance * 100) + "%"
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
	update_hud.emit(active)
	anim_player.play("activate")
	# reset values
	remaining_walk_range = WALK_RANGE
	remaining_actions = MAX_ACTIONS
	# fix astar pathing
	map.set_position_solid(position, false)
	# UI
	if target_find():
		center_screen()

func end_turn():
	if !action_timer.is_stopped:
		await action_timer.timeout
	active = false
	update_hud.emit(active)
	map.clear_highlights()
	# Notification for passing turn with remaining actions
	if remaining_actions > 0:
		var pass_text = t.instantiate()
		pass_text.set_text("PASS")
		add_child(pass_text)
	# fix astar pathing
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
	if !visible:
		return
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(camera, "zoom", Vector2(camera.ZOOM_MAX, camera.ZOOM_MAX), ZOOM_TIME)
	var pos = position
	if target != Vector2(-666, -666):
		pos = (pos + target) / 2
	camera.position = pos

func walk(click_position: Vector2, walk_range: int = remaining_walk_range) -> bool:
	if map.can_walk(position, click_position, walk_range):
		remaining_walk_range -= map.get_walk_distance(position, click_position)
		# Player Characters and Ally NPC unique
		if is_sig:
			# Iterate along walking path taken
			for pos in map.get_walk_path(position, click_position):
				# clear fog of war
				_clear_fog(map.map_to_local(pos), SIGHT_RANGE)
				# pickup non-actors
				var non = manager.remove_non_actors_at_position(map.map_to_local(pos))
				for a in non:
					inventory.push_back(true)
					print (inventory)
		# move actor
		select(SELECT_TYPE_NONE)
		_face(click_position)
		anim.play("idle " + facing)
		position = map.get_center(click_position)
		# fog of war visibility
		if !is_sig and map.is_in_fog(position) and visible:
			visible = false
		elif !is_sig and !map.is_in_fog(position) and !visible:
			visible = true
		
		if remaining_walk_range > 0:
			select(SELECT_TYPE_WALK)
		return true
	else:
		return false

func attack(attacker: Actor) -> int:				## Attack vs. this player.
	var is_hidden = map.is_in_fog(attacker.position)
	# reveal temporarily if hidden
	if is_hidden:
		_clear_fog(attacker.position, 0)
		center_screen((position + attacker.position) / 2)
	
	var damage_text = t.instantiate()
	var damage: int = 0
	if rng.randf() < hit_chance(attacker):
		var text_type = damage_text.TEXT_TYPE_NEGATIVE
		if rng.randf() < attacker.BASE_CRIT_CHANCE + attacker.crit_modifier:
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
	
	if is_hidden:
		action_timer.start()
		await action_timer.timeout
		_set_fog(attacker.position, 0)
	
	return damage

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
		SELECT_TYPE_NONE:
			if is_exhausted():
				return false
			map.clear_highlights()
		SELECT_TYPE_WALK:
			if remaining_walk_range <= 0:
				return false
			if visible:
				map.draw_range(position, remaining_walk_range)
		SELECT_TYPE_ATTACK:
			if remaining_actions <= 0:
				return false
			if visible:
				map.draw_range(position, attack_range, false)
		SELECT_TYPE_SPELL:
			if remaining_actions <= 0 or !Util.is_in_range(spell_pointer, spell_book) or mp < spell_book[spell_pointer].mana_cost:
				return false
			if visible:
				map.draw_range(position, spell_book[spell_pointer].attack_range, false)
		SELECT_TYPE_ABILITY:
			if remaining_actions <= 0 or !Util.is_in_range(ability_pointer, abilities):
				return false
			if visible:
				abilities[ability_pointer].effect(self, map)
		SELECT_TYPE_INVENTORY:
			if remaining_actions <= 0 or !Util.is_in_range(inventory_pointer, inventory):
				return false
			if visible:
				map.draw_range(position, inventory[inventory_pointer].attack_range, false)
		_:
			return false
	select_type = new_type
	return true

func target_find() -> bool:
	return true

# private methods
func _set_fog(origin: Vector2, radius: int):
	map.set_fog(origin, radius)
	for actor in manager.get_all_actors():
		if actor.visible and map.is_in_fog(actor.position):
			actor.visible = false

func _clear_fog(origin: Vector2, radius: int):
	map.clear_fog(origin, radius)
	for actor in manager.get_all_actors():
		if actor.visible and map.is_in_fog(actor.position):
			actor.visible = false
		elif !actor.visible and !map.is_in_fog(actor.position):
			actor.visible = true

func _do_action_grid(click_position: Vector2i) -> bool:
	return await _do_action(map.ground_layer.map_to_local(click_position))

func _do_action(click_position: Vector2) -> bool:
	# Walk
	match select_type:
		SELECT_TYPE_WALK:
			walk(click_position)
	
	# Attack
		SELECT_TYPE_ATTACK when (map.can_see(position, click_position, attack_range) and remaining_actions > 0):
			# shoot if valid targets
			var targets = manager.get_actors_at_position(click_position)
			# break if invalid attack targets
			if targets.is_empty() or targets.has(self):
				return false
			remaining_actions -= 1
			if remaining_actions <= 0:
				remaining_walk_range = 0
			_face(click_position)
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
				await target.attack(self)
			# Reset selection
			select(SELECT_TYPE_NONE)
	
		# Spellcast
		SELECT_TYPE_SPELL when (map.can_see(position, click_position, spell_book[spell_pointer].attack_range) and mp >= spell_book[spell_pointer].mana_cost and remaining_actions > 0):
			# shoot if valid targets
			var targets = manager.get_actors_at_position(click_position)
			# break if invalid attack targets
			if targets.is_empty() or targets.has(self):
				return false
			remaining_actions -= 1
			mp -= spell_book[spell_pointer].mana_cost
			if remaining_actions <= 0:
				remaining_walk_range = 0
			_face(click_position)
			# range or melee animation
			if spell_book[spell_pointer].attack_range > melee_range:
				anim.play("shoot " + facing)
			else:
				anim.play("swing " + facing)
			# Attack all targets
			for target in targets:
				if chance_text != null:
					chance_text.queue_free()
					chance_text = null
				target._face(position)
				spell_book[spell_pointer].attack(self, target)
			# Reset selection
			select(SELECT_TYPE_NONE)
	
		# Ability
		SELECT_TYPE_ABILITY:
			remaining_actions -= int(abilities[ability_pointer].effect(self, map, click_position))
			# Reset selection
			select(SELECT_TYPE_NONE)
	# Pass
		_:
			return false
	
	# Loop
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
