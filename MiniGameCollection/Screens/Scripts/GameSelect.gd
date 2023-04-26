extends Control

signal game_selected

const _GAMES: Array[String] = [
	"res://Games/ShapeEscape/ShapeEscape.tscn"
]

@onready var _button_order = [
	$ShapeEscapeButton
]

func _ready():
	for i in range(_button_order.size()):
		_button_order[i].pressed.connect(_button_pressed.bind(i))

func _button_pressed(index: int):
	game_selected.emit(_GAMES[index])
