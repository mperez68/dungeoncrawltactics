extends Button

func _ready() -> void:
	if !CharacterList.is_node_ready():
		await CharacterList.ready
	if !CharacterList.all_actors.is_empty():
		visible = true
