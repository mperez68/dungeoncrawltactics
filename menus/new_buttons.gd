extends HBoxContainer

@onready var soldier_button = $Soldier
@onready var archer_button = $Archer
@onready var wizard_button = $Wizard


func _ready() -> void:
	update_options()

func _on_button_pressed(_button_class: String) -> void:
	update_options()

func update_options():
	if CharacterList.total_treasure >= 3:
		soldier_button.disabled = false
		archer_button.disabled = false
		wizard_button.disabled = false
	else:
		soldier_button.disabled = true
		archer_button.disabled = true
		wizard_button.disabled = true
		
