extends Node2D

signal init_camera(origin: Vector2, limit: Vector2)

var hl = preload("res://highlightrect.tscn")

@onready var ground_layer = $Ground
@onready var wall_layer = $Vantage
@onready var terrain_layer = $Terrain
@onready var offset = Vector2(ground_layer.tile_set.tile_size.x / 2, ground_layer.tile_set.tile_size.y / 2)
@onready var rect = ground_layer.get_used_rect()

var astar = AStarGrid2D.new()
var highlights = []
var tilemap_size

func _ready():
	init_camera.emit(rect.position * ground_layer.tile_set.tile_size, rect.end * ground_layer.tile_set.tile_size)
	
	# Astar init
	tilemap_size = rect.end
	astar.region = Rect2i(Vector2i.ZERO , tilemap_size)
	astar.cell_size = ground_layer.get_tile_set().tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	# populate solids
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coords = Vector2i(i, j)
			var wall_data = wall_layer.get_cell_tile_data(coords)
			var ground_data = ground_layer.get_cell_tile_data(coords)
			var terrain_data = terrain_layer.get_cell_tile_data(coords)
			if terrain_data or !ground_data or (ground_data.get_custom_data("pathing") == "water" and !wall_data) or (wall_data and wall_data.get_custom_data("pathing") == "wall"):
				astar.set_point_solid(coords)
			if wall_data and wall_data.get_custom_data("pathing") == "ramp":
				astar.set_point_weight_scale(coords, 2)

func get_center(local: Vector2):
	return ground_layer.map_to_local(ground_layer.local_to_map(local))

func can_stand(local: Vector2) -> bool:
	var coords = ground_layer.local_to_map(local)
	return ground_layer.get_cell_tile_data(coords) != null and not astar.is_point_solid(coords)

func can_walk(start: Vector2, end: Vector2, max_distance: int = 999999) -> bool:
	var path_length = _weighted_path(start, end)
	return path_length > 0 and path_length <= max_distance

func get_walk_distance(start: Vector2, end: Vector2) -> int:
	var path_length = _weighted_path(start, end)
	if path_length == 0:
		return -1
	return path_length

func _weighted_path(start: Vector2, end: Vector2) -> int:
	var path = astar.get_id_path(ground_layer.local_to_map(start), ground_layer.local_to_map(end)).slice(1)
	var result = 0
	for id in path:
		result += astar.get_point_weight_scale(id)
	return result

func is_vantage(origin: Vector2) -> bool:
	var cell = wall_layer.get_cell_tile_data(wall_layer.local_to_map(origin))
	return cell and cell.get_custom_data("pathing") == "vantage"

func can_see(start: Vector2, end: Vector2, max_distance: int = 999999, obscuring_depth: int = 2) -> bool:
	var distance = Vector2i( abs(local_to_map(start).x - local_to_map(end).x), abs(local_to_map(start).y - local_to_map(end).y) )
	if distance.length() > max_distance:
		return false
	
	var line = get_line(start, end)
	
	# walls and terrain block vision
	if !is_vantage(start) and line.size() > obscuring_depth:
		if obscuring_depth > 0:
			line = line.slice(0, -obscuring_depth)
		for point in line:
			var wall = wall_layer.get_cell_tile_data(point)
			var terrain = terrain_layer.get_cell_tile_data(point)
			if (wall and wall.get_custom_data("pathing") == "wall") or (terrain and point != line[0]):
				return false
	elif is_vantage(start):
		var walls = 0
		var wall
		var is_wall = false
		for point in line:
			wall = wall_layer.get_cell_tile_data(point)
			if is_vantage(ground_layer.map_to_local(point)) or (wall and wall.get_custom_data("pathing") != ""):
				is_wall = true
			elif is_wall:
				walls += 1
				is_wall = false
		if is_wall:
			walls += 1
			is_wall = false
		wall = wall_layer.get_cell_tile_data(local_to_map(end))
		if walls > 1 and !is_vantage(end) and !(wall and wall.get_custom_data("pathing") == "wall"):
			print(local_to_map(end), "--", walls)
			return false
	
	return true

func set_position_solid(local: Vector2, solid: bool = true):
	astar.set_point_solid(local_to_map(local), solid)

func local_to_map(local: Vector2):
	return ground_layer.local_to_map(local)

func draw_range(origin: Vector2, max_distance: int = 999999, walking: bool = true):
	if walking and !can_stand(origin):
		return
	
	# repopulate highlights
	clear_highlights()
	for i in range(local_to_map(origin).x -  max_distance, local_to_map(origin).x + max_distance + 1):
		for j in range(local_to_map(origin).y -  max_distance, local_to_map(origin).y +  max_distance + 1):
			var target_global = ground_layer.map_to_local(Vector2i(i, j))
			if (walking and can_walk(origin, target_global, max_distance)) or (!walking and can_see(origin, target_global, max_distance)):
				var temp = hl.instantiate()
				temp.position = target_global - offset
				add_child(temp)
				highlights.push_front(temp)

func clear_highlights():
	for h in highlights:
		h.queue_free()
	highlights = []

# util
func get_orthogonal_line(origin: Vector2, target: Vector2) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var g_origin = local_to_map(origin)
	var g_target = local_to_map(target)
	if g_origin == g_target:
		return points
	var dif = g_target - g_origin
	var abs_dif = abs(dif)
	var walk_dir = Vector2i(1, 1)
	if dif.x < 0:
		walk_dir.x = -1
	if dif.y < 0:
		walk_dir.y = -1
	
	var i = Vector2i(0, 0)
	var p = Vector2i(0, 0)
	
	while(true):
		if (0.5 + i.x) / abs_dif.x < (0.5 + i.y) / abs_dif.y:
			p.x += walk_dir.x
			i.x += 1
		else:
			p.y += walk_dir.y
			i.y += 1
		points.push_back(Vector2i(p) + g_origin)
		
		if (abs_dif.x <= i.x and abs_dif.y <= i.y):
			break
	
	return points

func get_line(origin: Vector2, target: Vector2) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	
	var length: float = diagonal_distance(origin, target)
	for i in length:
		points.push_back(local_to_map(lerp(origin, target, i / length)))
	
	return points.slice(1)

func diagonal_distance(origin: Vector2, target: Vector2) -> int:
	var dif = local_to_map(origin - target)
	return max(abs(dif.x), abs(dif.y))
