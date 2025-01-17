extends AnimatedSprite2D

class_name Ability

enum type{ NO_TARGET, POSITION, SINGLE_TARGET, MULTI_TARGET }

@export var NAME: String = "Ability"
@export var texture_normal: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_pressed: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_hover: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_disabled: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_focused: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_click_mask: CompressedTexture2D = preload("res://png/spells/spell_tile.png")

@export var ability_type: type = type.NO_TARGET

var rng = RandomNumberGenerator.new()
var map: Map
const t = preload("res://ui/fading_text.tscn")

func effect(user: Actor, map: Map = null, target: Variant = null) -> bool:
	self.map = map
	var ret : bool = true
	match ability_type:
		type.NO_TARGET:
			ret = _effect_no_target(user)
		type.POSITION:
			if target == null:
				target = Vector2.ZERO
			ret = _effect_vector(user, target)
		type.SINGLE_TARGET:
			ret = _effect_actor(user, target)
		type.MULTI_TARGET:
			ret = _effect_actor_array(user, target)
		_:
			ret = false
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


# Engine
func _on_animation_finished() -> void:
	if animation.contains("hit") and get_parent():
		get_parent().remove_child(self)
