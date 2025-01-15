extends Actor

class_name PlayerActor


# Inputs
func _unhandled_input(event: InputEvent) -> void:
	# No actions can be done while not active actor
	if !active:
		return
	
	# Mouse events
	if event is InputEventMouse:
		var map_coords = ((event.position - (camera.get_viewport_rect().end / 2))/ camera.zoom) + camera.position
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			input_timer.start()
			await input_timer.timeout
			await _do_action(map_coords)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			input_timer.start()
			await input_timer.timeout
			var temp = select_type
			select(SELECT_TYPE_ATTACK)
			if await _do_action(map_coords):
				select(temp)
			else:
				select(SELECT_TYPE_NONE)


# public methods
func start_turn():
	super()
	select(SELECT_TYPE_WALK)

func select(new_type: int) -> bool:
	var ret = super(new_type)
	match new_type:
		SELECT_TYPE_NONE:
			if is_exhausted():
				end_turn()
	return ret

# Private methods
func _do_action(click_position: Vector2) -> bool:
	var ret = await super(click_position)
	
	# calculate objectives
	for objective in manager.objectives:
		if ret and map.local_to_map(position) == map.local_to_map(objective) and !inventory.is_empty() and inventory[0]:
			manager.end_game()
	
	return ret
