extends Actor

class_name NPCActor

# reference
@onready var action_pause = $ActionPause

# constants
const PAUSE_SHORT = 0.3
const PAUSE_LONG = 1


# public methods
func start_turn():
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


# private methods
func _ai_turn() -> bool:
	var ret = true
	
	var live = 0
	for actor in manager.actors:
		if actor.hp > 0:
			live += 1
	if live <= 1:
		return false
	
	var target_index = index
	while(target_index == index or manager.actors[target_index].hp <= 0):
		target_index = randi_range(0, manager.actors.size() - 1)
	var target = manager.actors[target_index]
	
	# shoot; if can't, move: if can't, do nothing
	if remaining_actions > 0 and map.can_see(position, target.position, attack_range):
		if select_type == SELECT_TYPE_ATTACK:
			_do_action(target.position)
		else:
			select(SELECT_TYPE_ATTACK)
			center_screen(target.position)
	elif remaining_walk_range > 0:
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
