extends NonActor
class_name EquipmentActor

@onready var data = $Data
@onready var description: String = data.description
@onready var treasure_cost: int = data.treasure_cost
@export var texture_normal = preload("res://png/spells/spell_tile.png")

func effect(user: Actor, map_in: Map, target = null) -> bool:
	return data.effect(user, map_in, target)
