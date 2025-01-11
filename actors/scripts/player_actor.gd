extends Actor

class_name PlayerActor

func _ready():
	super()
	sig = true

# Inputs
func _input(event: InputEvent) -> void:
	# No actions can be done while not active actor
	if !active:
		return
	
	# Mouse events
	if event is InputEventMouse:
		var map_coords = ((event.position - (camera.get_viewport_rect().end / 2))/ camera.zoom) + camera.position
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_do_action(map_coords)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var temp = select_type
			select(SELECT_TYPE_ATTACK)
			_do_action(map_coords)
			select(temp)


# public methods
func start_turn():
	super()
	select(SELECT_TYPE_WALK)

func select(new_type: int) -> bool:
	var ret = super(new_type)
	if ret:
		match new_type:
			SELECT_TYPE_WALK:
				map.draw_range(position, remaining_walk_range)
			SELECT_TYPE_ATTACK:
				map.draw_range(position, attack_range, false)
	return ret
