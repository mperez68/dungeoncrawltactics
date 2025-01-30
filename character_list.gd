extends Node

enum MUSIC_STATE{ OFF, MENU, COVE }
enum LEVEL{ DEFAULT, LEVEL_1, LEVEL_2, LEVEL_3 }

const SAVE_PATH = "user://game.save"
const SAVE_ACTORS_PATH_PRE = "user://actor"
const SAVE_ACTORS_PATH_POST = ".tscn"

@onready var menu_music = $MenuMusic
@onready var cove_music = $LevelIntro
@onready var cove_music_loop = $LevelLoop

var all_actors: Array[PlayerActor] = []
var final_loadout: Array[PlayerActor] = []
var total_treasure: int = 5
var music_state = MUSIC_STATE.OFF
var current_level = LEVEL.LEVEL_1

var generic_options: Array[Node] = [ preload("res://actors/pickups/health_potion_actor.tscn").instantiate(), preload("res://actors/pickups/mana_potion_actor.tscn").instantiate() ]
var soldier_options: Array[Node] = [ preload("res://actions/block.tscn").instantiate() ]
var archer_options: Array[Node] = [ preload("res://actions/dash.tscn").instantiate() ]
var wizard_options: Array[Node] = [ preload("res://actions/immolate.tscn").instantiate() ]

func _ready() -> void:
	# Load if valid save
	load_data()

func new_game():
	all_actors.clear()
	total_treasure = 5
	save_data()

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(total_treasure)
	var scene = PackedScene.new()
	for i in all_actors.size():
		var temp_path = SAVE_ACTORS_PATH_PRE + str(i) + SAVE_ACTORS_PATH_POST
		scene.pack(all_actors[i].duplicate())
		print(all_actors[i].NAME, " => ", temp_path, " ?= ", ResourceSaver.save(scene, temp_path))
	print("Game data saved")

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		print("found game data at ", SAVE_PATH)
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		total_treasure = file.get_var()
		var i: int = 0
		while(true):
			var temp_path = SAVE_ACTORS_PATH_PRE + str(i) + SAVE_ACTORS_PATH_POST
			if ResourceLoader.exists(temp_path):
				all_actors.push_back(ResourceLoader.load(temp_path).instantiate())
				print("loaded " + all_actors[all_actors.size() - 1].NAME + " from " + temp_path)
			else:
				break
			i += 1
		
		file.close()
		print("game data loaded")
	else:
		print("New game data")

func add_actor(actor_class: String) -> int:
	var actor: PlayerActor
	match actor_class:
		"soldier":
			actor = preload("res://actors/player/soldier.tscn").instantiate()
		"archer":
			actor = preload("res://actors/player/archer.tscn").instantiate()
		"wizard":
			actor = preload("res://actors/player/wizard.tscn").instantiate()
	actor.gen_name()
	actor.init_specials()
	all_actors.push_front(actor)
	return 0	# index of added actor

func get_menu_actor(index: int) -> MenuActor:
	var arg: MenuActor.Type = MenuActor.Type.DEFAULT
	var actor: MenuActor
	actor = preload("res://ui/menu_actor.tscn").instantiate()
	if range(all_actors.size()).has(index):
		if all_actors[index] is Soldier:	# I hate this, make it a match statement if possible
			arg = MenuActor.Type.SOLDIER
		elif all_actors[index] is Archer:
			arg = MenuActor.Type.ARCHER
		elif all_actors[index] is Wizard:
			arg = MenuActor.Type.WIZARD
		actor.init(arg, all_actors[index])
		actor.actor_name = all_actors[index].NAME
	return actor

func get_menu_actor_from_player_actor(player_actor: PlayerActor) -> MenuActor:
	var arg: MenuActor.Type = MenuActor.Type.DEFAULT
	var actor: MenuActor
	actor = preload("res://ui/menu_actor.tscn").instantiate()
	if player_actor is Soldier:	# I hate this, make it a match statement if possible
		arg = MenuActor.Type.SOLDIER
	elif player_actor is Archer:
		arg = MenuActor.Type.ARCHER
	elif player_actor is Wizard:
		arg = MenuActor.Type.WIZARD
	actor.init(arg, player_actor)
	actor.actor_name = player_actor.NAME
	return actor

func open_level(new_level: LEVEL):
	current_level = max(new_level, current_level)

func change_music(state: MUSIC_STATE = MUSIC_STATE.OFF):
	if music_state == state:
		return
	music_state = state
	menu_music.stop()
	cove_music.stop()
	cove_music_loop.stop()
	match music_state:
		MUSIC_STATE.OFF:
			print("stopping music")
		MUSIC_STATE.MENU:
			print("starting menu music")
			menu_music.play()
		MUSIC_STATE.COVE:
			print("starting cove music")
			cove_music.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.is_pressed():
		$MouseClick.play()


func _on_menu_music_finished() -> void:
	$MenuDelay.start()


func _on_menu_delay_timeout() -> void:
	menu_music.play()


func _on_level_intro_finished() -> void:
	cove_music_loop.play()
