extends HBoxContainer

@onready var soldier_button = $Soldier
@onready var archer_button = $Archer
@onready var wizard_button = $Wizard


func _ready() -> void:
	# TODO get options from singleton
	soldier_button.disabled = false
	archer_button.disabled = false
	wizard_button.disabled = false

func _on_button_pressed(button_class: String) -> void:
	# only one new character a round
	soldier_button.disabled = true
	archer_button.disabled = true
	wizard_button.disabled = true
