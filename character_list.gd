extends Node

var all_actors: Array[PlayerActor] = []
var final_loadout: Array[PlayerActor] = []

# Save to local data on mission completion

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
