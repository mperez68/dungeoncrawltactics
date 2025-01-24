extends ItemList

signal send_to_loadout(actor: MenuActor)
signal update_selected_actor(actor: MenuActor)

@onready var button = $"../AddToLoadout"

var lock = false
var roster: Array[MenuActor] = []


func _ready() -> void:
	clear()
	roster.clear()
	for i in CharacterList.all_actors.size():
		_add(CharacterList.get_menu_actor(i))


func _on_pregame_screen_deselect_roster() -> void:
	deselect_all()


func _on_pregame_screen_roster_to_loadout(index: int) -> void:
	if range(roster.size()).has(index) and !lock:
		send_to_loadout.emit(roster[index])
		roster.remove_at(index)
		remove_item(index)


func _on_pregame_screen_add_actor(actor: MenuActor) -> void:
	_add(actor)


func _on_loadout_send_to_roster(actor: MenuActor) -> void:
	_add(actor)


func _add(actor: MenuActor):
	roster.push_back(actor)
	add_item(actor.actor_name) #TODO add icon


func _on_item_selected(index: int) -> void:
	update_selected_actor.emit(roster[index])


func _on_loadout_lock_loadout(is_locked: int) -> void:
	lock = is_locked
	button.disabled = is_locked
