extends Actor

class_name NPCActor

# references
@onready var aggro_highlight = $AggroRadius


# constants
const PAUSE_SHORT: float = 0.3
const PAUSE_LONG: float = 1
const CYCLE_LIMIT: int = 20

# Variables
@export var target: Actor = null
@export var aggro_range: int = 10
@export var patrol_route: Array[Vector2i] = []
var patrol_pointer = 0

# engine
func _ready() -> void:
	super()
	aggro_highlight.radius = 16 * aggro_range

func _on_mouse_entered() -> void:
	super()
	
	if hp > 0 and target == null:
		aggro_highlight.visible = true

func _on_mouse_exited() -> void:
	super()
	
	aggro_highlight.visible = false


# public methods
func start_turn():
	super()
	var cycles = 0
	while await _ai_turn() and cycles < CYCLE_LIMIT:
		cycles += 1
		if visible and select_type == SELECT_TYPE_WALK:
			action_timer.start(PAUSE_SHORT)
			await action_timer.timeout
		elif visible:
			action_timer.start(PAUSE_LONG)
			await action_timer.timeout
	end_turn()

func target_find() -> bool:
	if hp <= 0:
		return false
	
	if target and target.get_parent() == null:
		target = null
	
	var ret = false
	var distance = 9999
	var best_target: Actor = target
	var is_aggro = false
	if target and target.hp > 0:
		is_aggro = true
		distance = map.get_walk_distance(position, target.position, true)
		ret = true
	elif target and target.hp <= 0:
		is_aggro = true
		target = null
	for actor in manager.actors:
		var temp = map.get_walk_distance(position, actor.position, true)
		if actor.hp > 0 and actor.is_sig and map.can_see(position, actor.position, aggro_range) and temp < distance and temp > 0:
			distance = temp
			best_target = actor
			ret = true
	if !is_aggro and best_target:
		aggro(best_target)
	if !ret:
		target = null
		is_aggro = false
	return ret

func aggro(aggro_target: Actor, primary_aggro: bool = true):
	if hp <= 0:
		return
	# Assign new target
	target = aggro_target
	if primary_aggro:
		action_timer.start()
		await action_timer.timeout
	var aggro_text = t.instantiate()
	aggro_text.set_text("!!!", aggro_text.TEXT_TYPE_NEGATIVE)
	add_child(aggro_text)
	# Aggro nearby units
	if primary_aggro:
		for actor in manager.actors:
			if actor != self and !actor.is_sig and map.can_see(actor.position, position, actor.aggro_range / 2):
				actor.aggro(aggro_target, false)

func attack(attacker: Actor) -> int:
	var ret =  await super(attacker)
	
	if target == null and hp > 0:
		aggro(attacker)
	
	return ret

# private methods
func _ai_turn() -> bool:
	if debug:
		print(NAME, " ->", map.local_to_map(position), "::move=", remaining_walk_range, "::actions=", remaining_actions)
	var ret = true
	# Find new target if current target is dead
	if target and target.hp <= 0:
		target_find()
	
	# shoot target
	if target and remaining_actions > 0 and map.can_see(position, target.position, attack_range):
		if select_type == SELECT_TYPE_ATTACK:
			await _do_action(target.position)
		else:
			select(SELECT_TYPE_ATTACK)
			center_screen(target.position)
	# move towards range of target
	elif target and remaining_walk_range > 0:
		var beeline_point = map.get_nearest_tile(position, target.position, attack_range)
		
		var astar_path = map._weighted_path(position, target.position, true)
		var beeline_path = map._weighted_path(position, map.map_to_local(beeline_point))
		
		if map.can_see(map.map_to_local(beeline_point), target.position, attack_range) and beeline_path <= astar_path and remaining_walk_range >= map._weighted_path(position, map.map_to_local(map.get_step_towards(position, map.map_to_local(beeline_point)))):
			if select_type != SELECT_TYPE_WALK:
				select(SELECT_TYPE_WALK)
			elif await _do_action_grid(map.get_step_towards(position, map.map_to_local(beeline_point))):
				center_screen(position)
		elif map.can_approach(position, target.position, 9999, true) and remaining_walk_range >= map._weighted_path(position, map.map_to_local(map.get_step_towards(position, target.position))):
			if select_type != SELECT_TYPE_WALK:
				select(SELECT_TYPE_WALK)
			elif await _do_action_grid(map.get_step_towards(position, target.position)):
				center_screen(position)
			else:
				ret = false
		else:
			ret = false
	# patrol
	elif patrol_route.size() > 1 and remaining_walk_range > 0:
		if map.local_to_map(position) == patrol_route[patrol_pointer]:
			patrol_pointer = (patrol_pointer + 1) % patrol_route.size()
		elif !map.can_approach(position, map.map_to_local(patrol_route[patrol_pointer]), 9999) and map.can_see(position, patrol_route[patrol_pointer], int(aggro_range / 2)):
			patrol_pointer = (patrol_pointer + 1) % patrol_route.size()
		else:
			if select_type != SELECT_TYPE_WALK:
				select(SELECT_TYPE_WALK)
			elif await _do_action_grid(map.get_step_towards(position, map.map_to_local(patrol_route[patrol_pointer]))):
				center_screen(position)
	# If no valid actions, pass turn
	else:
		ret = false
	
	# break loop if no actions remaining
	if remaining_actions + remaining_walk_range <= 0:
		ret = false
	return ret

func walk(click_position: Vector2, walk_range: int = remaining_walk_range) -> bool:
	var ret = super(click_position, walk_range)
	
	target_find()
	
	return ret
