extends Control

signal level_selected
signal back_pressed

@onready var _button_order =  [
	$Level1Button,
	$Level2Button,
	$Level3Button,
	$Level4Button,
	$Level5Button,
]

func set_button_enabled_states(states: Array[bool]):
	for i in range(states.size()):
		_button_order[i].disabled = not states[i]

func _ready():
	for i in range(_button_order.size()):
		_button_order[i].pressed.connect(_on_button_pressed.bind(i))

func _on_button_pressed(button_index: int):
	level_selected.emit(button_index)

func _on_back_button_pressed():
	back_pressed.emit()
