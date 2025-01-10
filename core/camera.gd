extends Camera2D

const PAN_SPEED = 1024
const ZOOM_MAX = 3
const ZOOM_MIN = 1

var pan_vector = Vector2(0, 0)
var half_screen: Vector2i
var orig: Vector2
var lim: Vector2

func _ready() -> void:
	resize()
	get_tree().get_root().size_changed.connect(resize)

func resize():
	half_screen = get_viewport().size / 2
	half_screen.x /= round(zoom.x)
	half_screen.y /= round(zoom.y)
	limit_left = round(orig.x) - half_screen.x
	limit_top = round(orig.y) - half_screen.y
	limit_right = round(lim.x) + half_screen.x
	limit_bottom = round(lim.y) + half_screen.y

func _process(delta):
	# Scroll with keyboard
	if Input.is_action_pressed("ui_left"):
		pan_vector.x = -PAN_SPEED
	elif Input.is_action_pressed("ui_right"):
		pan_vector.x = PAN_SPEED
	else:
		pan_vector.x = 0
	
	if Input.is_action_pressed("ui_up"):
		pan_vector.y = -PAN_SPEED
	elif Input.is_action_pressed("ui_down"):
		pan_vector.y = PAN_SPEED
	else:
		pan_vector.y = 0
	
	# center within boundaries
	position += pan_vector * delta
	position.x = max(position.x, limit_left + half_screen.x)
	position.x = min(position.x, limit_right - half_screen.x)
	position.y = max(position.y, limit_top + half_screen.y)
	position.y = min(position.y, limit_bottom - half_screen.y)


func _input(event):
	# Scroll with mouse
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= (event.relative * 1 / zoom)
		position_smoothing_enabled = false
	else:
		position_smoothing_enabled = true
	
	# Zoom
	if event is InputEventMouseButton and event.is_pressed():
		var result = zoom.x
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			result = min(zoom.x + 0.1, ZOOM_MAX)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			result = max(zoom.x - 0.1, ZOOM_MIN)
		zoom = Vector2(result, result)


func _on_map_init_camera(origin: Vector2, limit: Vector2) -> void:
	orig = origin
	lim = limit
	resize()
	position = origin + (limit / 2)
