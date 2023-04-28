extends Control

signal game_selected

const _GAMES := [
	"res://Games/ShapeEscape/ShapeEscape.tscn"
]

@onready var _button_order := [
	$ShapeEscapeButton
]

func _ready():
	for i in range(_button_order.size()):
		_button_order[i].pressed.connect(func(): game_selected.emit(_GAMES[i]))
