extends Actor

# reference
@onready var action_pause = $ActionPause


# public methods
func start_turn():
	super()
	while _ai_turn():
		action_pause.start()
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
	print(target.hp)
	
	# shoot; if can't, move: if can't, do nothing
	if remaining_actions > 0 and map.can_see(position, target.position):
		if select_type == SELECT_TYPE_ATTACK:
			remaining_actions -= 1
			_do_action(target.position)
		else:
			select(SELECT_TYPE_ATTACK)
	elif remaining_walk_range > 0:
		#print(remaining_walk_range, " ", target.hp)
		remaining_walk_range -= 1
	else:
		ret = false
	
	# break loop if no actions remaining
	if remaining_actions + remaining_walk_range <= 0:
		ret = false
	return ret
