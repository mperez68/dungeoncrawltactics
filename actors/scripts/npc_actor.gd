extends Actor

class_name NPCActor

# reference
@onready var action_pause = $ActionPause

# constants
const PAUSE_SHORT = 0.3
const PAUSE_LONG = 1

# Variables
@export var target: Actor = null
@export var aggro_range: int = 10


# public methods
func start_turn():
	super()
	if visible:
		action_pause.start()
		await action_pause.timeout
	while _ai_turn():
		if visible and select_type == SELECT_TYPE_WALK:
			action_pause.start(PAUSE_SHORT)
			await action_pause.timeout
		elif visible:
			action_pause.start(PAUSE_LONG)
			await action_pause.timeout
	end_turn()

func target_find() -> bool:
	var ret = false
	var distance = 9999
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
			target = actor
			ret = true
	if !is_aggro and target:
		# Aggro happens
		var aggro_text = t.instantiate()
		aggro_text.set_text("AGGRO", aggro_text.TEXT_TYPE_NEGATIVE)
		add_child(aggro_text)
	if !ret:
		target = null
	return ret

# private methods
func _ai_turn() -> bool:
	var ret = true
	# Find new target if current target is dead
	if target and target.hp <= 0:
		target_find()
	
	# shoot; if can't, move: if can't, do nothing
	if target and remaining_actions > 0 and map.can_see(position, target.position, attack_range):
		if select_type == SELECT_TYPE_ATTACK:
			_do_action(target.position)
		else:
			select(SELECT_TYPE_ATTACK)
			center_screen(target.position)
	elif target and remaining_walk_range > 0:
		if map.can_approach(position, target.position):
			if select_type != SELECT_TYPE_WALK:
				select(SELECT_TYPE_WALK)
			elif _do_action_grid(map.get_step_towards(position, target.position)):
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
