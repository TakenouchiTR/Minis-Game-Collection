extends "res://Games/Game.gd"

const _SAVE_VERSION := 1
const _SAVE_DIR := "user://data/shape_escape/"
const _FILE_PATH := _SAVE_DIR + "shape_escape.dat"
const _MAIN_MENU := preload("res://Games/ShapeEscape/Screens/MainMenu.tscn")
const _LEVEL_SELECT := preload("res://Games/ShapeEscape/Screens/LevelSelect.tscn")
const _LEVELS := [
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel1.tscn"),
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel2.tscn"),
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel3.tscn"),
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel4.tscn"),
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel5.tscn"),
]

@onready var _canvas_layer := $CanvasLayer

var _unlocked_levels: Array[bool]= [
	true,
	false,
	false,
	false,
	false,
]

var _current_level_index := 0
var _current_screen

func _ready():
	match _get_save_version():
		1: _load_data_version_1()
	_load_main_menu()

## Saves the current session to file.
func _save_data():
	if not DirAccess.dir_exists_absolute(_SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(_SAVE_DIR)
	var file = FileAccess.open(_FILE_PATH, FileAccess.WRITE)

	print(FileAccess.get_open_error())
	var save_data: int = 0
	for i in range(_unlocked_levels.size()):
		if _unlocked_levels[i]:
			save_data |= 1 << i
	
	file.store_32(_SAVE_VERSION)
	file.store_32(save_data)
	file.close()

func _get_save_version() -> int:
	if not FileAccess.file_exists(_FILE_PATH):
		return 0
	var file := FileAccess.open(_FILE_PATH, FileAccess.READ)
	var version := file.get_32()
	file.close()
	return version

func _load_data_version_1():
	if not FileAccess.file_exists(_FILE_PATH):
		return
	var file = FileAccess.open(_FILE_PATH, FileAccess.READ)
	
	file.get_32()
	var save_data = file.get_32()
	file.close()
	
	for i in range(_unlocked_levels.size()):
		_unlocked_levels[i] = save_data & (1 << i) != 0

func _load_main_menu():
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = _MAIN_MENU.instantiate()
	_canvas_layer.add_child.call_deferred(_current_screen)
	
	_current_screen.connect("level_select_pressed", func(): _load_level_select())
	_current_screen.connect("quit_pressed", func(): game_ended.emit())

func _load_level_select():
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = _LEVEL_SELECT.instantiate()
	_canvas_layer.add_child.call_deferred(_current_screen)
	
	_current_screen.connect("back_pressed", func(): _load_main_menu())
	_current_screen.connect("level_selected", func(index: int):
		_current_level_index = index
		_change_levels(_LEVELS[index])
	)
	_current_screen.set_button_enabled_states.call_deferred(_unlocked_levels)

func _change_levels(level: Resource):
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = level.instantiate()
	add_child.call_deferred(_current_screen)
	
	_current_screen.connect("retry_level", func(): _change_levels(_LEVELS[_current_level_index]))
	_current_screen.connect("game_quit", func(): _load_level_select())
	_current_screen.connect("level_won", func():
		if _current_level_index == len(_LEVELS) - 1:
			return
	
		if _unlocked_levels[_current_level_index + 1]:
			return
	
		_unlocked_levels[_current_level_index + 1] = true
		_save_data()
	)
	_current_screen.connect("next_level", func(): 
		if _current_level_index == len(_LEVELS) - 1:
			_load_level_select()
			return
		
		_current_level_index += 1
		_change_levels(_LEVELS[_current_level_index])
	)
