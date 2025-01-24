extends ItemList

signal send_to_loadout(actor: MenuActor)

var roster: Array[MenuActor] = []

func _ready() -> void:
	clear()

func _on_pregame_screen_deselect_roster() -> void:
	deselect_all()


func _on_pregame_screen_new_actor(actor: MenuActor) -> void:
	_add(actor)


func _on_pregame_screen_roster_to_loadout(index: int) -> void:
	if range(roster.size()).has(index):
		send_to_loadout.emit(roster[index])
		roster.remove_at(index)
		remove_item(index)


func _on_loadout_send_to_roster(actor: MenuActor) -> void:
	_add(actor)

func _add(actor: MenuActor):
	roster.push_back(actor)
	add_item(actor.actor_name) #TODO add icon
