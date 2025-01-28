extends Node

class_name Equipment

enum type{ NO_TARGET, POSITION, SINGLE_TARGET, MULTI_TARGET }

@export var NAME: String = "Equipment"
@export var description: String = "text"
@export var treasure_cost: int = 1
@export var texture_normal: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_pressed: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_hover: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_disabled: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_focused: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_click_mask: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var ability_type: type = type.NO_TARGET

var rng = RandomNumberGenerator.new()
var map: Map
@export var count: int = 1
const t = preload("res://ui/fading_text.tscn")

func effect(user: Actor, map_in: Map = null, target: Variant = null) -> bool:
	if count <= 0:
		return false
	map = map_in
	var ret : bool = true
	match ability_type:
		type.NO_TARGET:
			ret = _effect_no_target(user)
		type.POSITION:
			if target == null:
				target = Vector2.ZERO
			ret = _effect_vector(user, target)
		type.SINGLE_TARGET:
			if target == null:
				target = preload("res://actors/actor.tscn").instantiate()
			ret = _effect_actor(user, target)
		type.MULTI_TARGET:
			if target == null:
				target = [  ]
			ret = _effect_actor_array(user, target)
		_:
			ret = false
	count -= int(ret)
	return ret

func _effect_no_target(user: Actor) -> bool:
	print(user, " :: NO TARGET, NOT DEFINED")
	return false

func _effect_vector(user: Actor, target: Vector2) -> bool:
	print(user, "::", target, " :: VECTOR, NOT DEFINED")
	return false

func _effect_actor(user: Actor, target: Actor) -> bool:
	print(user, "::", target, " :: ACTOR, NOT DEFINED")
	return false

func _effect_actor_array(user: Actor, target: Variant) -> bool:
	print(user, "::", target, " :: ACTOR ARRAY, NOT DEFINED")
	return false
