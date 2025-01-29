extends NonActor
class_name EquipmentActor

@onready var data = $Data
@export var description: String
@export var treasure_cost: int
@export var texture_normal = preload("res://png/spells/spell_tile.png")

func effect(user: Actor, map_in: Map, target = null) -> bool:
	return data.effect(user, map_in, target)
