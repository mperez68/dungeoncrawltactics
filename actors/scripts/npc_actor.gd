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
	if !target_find():
		end_turn()
		return
	super()
	action_pause.start()
	await action_pause.timeout
	while _ai_turn():
		if select_type == SELECT_TYPE_WALK:
			action_pause.start(PAUSE_SHORT)
		else:
			action_pause.start(PAUSE_LONG)
		await action_pause.timeout
	end_turn()

func target_find() -> bool:
	var ret = false
	var distance = 9999
	
	if target:
		ret = true
	else:
		for actor in manager.actors:
			var temp = map.get_walk_distance(position, actor.position, true)
			if map.can_see(position, actor.position, aggro_range) and temp < distance and temp > 0:
				distance = temp
				target = actor
				ret = true
	return ret

# private methods
func _ai_turn() -> bool:
	var ret = true
	
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
	
	# break loop if no actions remaining
	if remaining_actions + remaining_walk_range <= 0:
		ret = false
	return ret
