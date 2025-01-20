extends NonActor
class_name EquipmentActor

@onready var data = $Data

func effect(user: Actor, map_in: Map, target = null) -> bool:
	return data.effect(user, map_in, target)
