extends AnimatedSprite2D
class_name MenuActor

enum Type { SOLDIER, ARCHER, WIZARD, DEFAULT }

@onready var manager = get_parent()
var type: Type = Type.DEFAULT
var actor_name: String = "Actor"
var actor_class: String = "None"
var abilities: Array[Ability] = []
var spells: Array[Spell] = []
var inventory: Array[EquipmentActor] = []
var actor_reference: PlayerActor

func init(type_in: Type, original_actor: PlayerActor) -> void:
	actor_reference = original_actor
	type = type_in
	match type:
		Type.SOLDIER:
			sprite_frames = preload("res://actors/scripts/Soldier.tres")
			actor_name = "a tough guy"
			actor_class = "Soldier"
		Type.ARCHER:
			sprite_frames = preload("res://actors/scripts/Archer.tres")
			actor_name = "a fast guy"
			actor_class = "Archer"
		Type.WIZARD:
			sprite_frames = preload("res://actors/scripts/Wizard.tres")
			actor_name = "a nerdy guy"
			actor_class = "Wizard"
	abilities = original_actor.abilities
	spells = original_actor.spell_book
	inventory = original_actor.inventory
	

func _ready() -> void:
	play("idle down")
	
	position.x = position.x - float(int(position.x) % 16) + 8
	position.y = position.y - float(int(position.y) % 16) + 8
