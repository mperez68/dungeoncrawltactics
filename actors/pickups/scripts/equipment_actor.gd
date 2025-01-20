extends NonActor
class_name EquipmentActor

@onready var data = $TreasureData

func effect(user: Actor, map_in: Map, target = null) -> bool:
	return data.effect(user, map_in, target)
