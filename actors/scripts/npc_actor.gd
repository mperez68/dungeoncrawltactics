extends Actor

class_name NPCActor


# constants
const PAUSE_SHORT = 0.3
const PAUSE_LONG = 1

# Variables
@export var target: Actor = null
@export var aggro_range: int = 10


# public methods
func start_turn():
	super()
	while await _ai_turn():
		if visible and select_type == SELECT_TYPE_WALK:
			action_timer.start(PAUSE_SHORT)
			await action_timer.timeout
		elif visible:
			action_timer.start(PAUSE_LONG)
			await action_timer.timeout
	end_turn()

func target_find() -> bool:
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

func aggro(aggro_target: Actor):
	target = aggro_target
	action_timer.start()
	await action_timer.timeout
	var aggro_text = t.instantiate()
	aggro_text.set_text("AGGRO", aggro_text.TEXT_TYPE_NEGATIVE)
	add_child(aggro_text)

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
	
	# shoot; if can't, move: if can't, do nothing
	if target and remaining_actions > 0 and map.can_see(position, target.position, attack_range):
		if select_type == SELECT_TYPE_ATTACK:
			await _do_action(target.position)
		else:
			select(SELECT_TYPE_ATTACK)
			center_screen(target.position)
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
	else:
		ret = false
	
	# break loop if no actions remaining
	if remaining_actions + remaining_walk_range <= 0:
		ret = false
	return ret
