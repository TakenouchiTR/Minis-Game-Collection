extends Node2D

const _GAME_SELECT = preload("res://Screens/GameSelect.tscn")

@onready var _canvas_layer = $CanvasLayer

var _current_screen

func _ready():
	_load_game_select()

func _load_game_select():
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = _GAME_SELECT.instantiate()
	_canvas_layer.add_child.call_deferred(_current_screen)
	
	_current_screen.connect("game_selected", _load_game)

func _load_game(game_path: String):
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = load(game_path).instantiate()
	add_child.call_deferred(_current_screen)
	
	_current_screen.connect("game_ended", _load_game_select)
