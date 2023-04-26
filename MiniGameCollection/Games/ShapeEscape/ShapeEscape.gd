extends "res://Games/Game.gd"

const _SAVE_DIR = "user://data/shape_escape/"
const _FILE_PATH = _SAVE_DIR + "shape_escape.dat"
const _MAIN_MENU = preload("res://Games/ShapeEscape/Screens/MainMenu.tscn")
const _LEVEL_SELECT = preload("res://Games/ShapeEscape/Screens/LevelSelect.tscn")
const _LEVELS: Array[Resource] = [
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel1.tscn"),
	preload("res://Games/ShapeEscape/Levels/ShapeEscapeLevel2.tscn"),
]

@onready var canvas_layer = $CanvasLayer

var _unlocked_levels: Array[bool] = [
	true,
	false,
]

var _current_level_index: int = 0
var _current_screen

func _ready():
	_load_data()
	load_main_menu()

func _save_data():
	if not DirAccess.dir_exists_absolute(_SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(_SAVE_DIR)
	var file = FileAccess.open(_FILE_PATH, FileAccess.WRITE)

	print(FileAccess.get_open_error())
	var save_data: int = 0
	for i in range(_unlocked_levels.size()):
		if _unlocked_levels[i]:
			save_data |= 1 << i
	
	file.store_32(save_data)
	file.close()

func _load_data():
	if not FileAccess.file_exists(_FILE_PATH):
		return
	var file = FileAccess.open(_FILE_PATH, FileAccess.READ)
	
	var save_data = file.get_32()
	file.close()
	
	for i in range(_unlocked_levels.size()):
		_unlocked_levels[i] = save_data & (1 << i) != 0

func load_main_menu():
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = _MAIN_MENU.instantiate()
	canvas_layer.add_child.call_deferred(_current_screen)
	
	_current_screen.connect("level_select_pressed", _main_menu_level_select_pressed)
	_current_screen.connect("quit_pressed", _main_menu_quit_pressed)

func load_level_select():
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = _LEVEL_SELECT.instantiate()
	canvas_layer.add_child.call_deferred(_current_screen)
	
	_current_screen.connect("back_pressed", _level_select_back_pressed)
	_current_screen.connect("level_selected", _level_select_level_selected)
	_current_screen.set_button_enabled_states.call_deferred(_unlocked_levels)

func change_levels(level: Resource):
	if _current_screen != null:
		_current_screen.queue_free()
	
	_current_screen = level.instantiate()
	add_child.call_deferred(_current_screen)
	
	_current_screen.connect("level_won", _current_level_won)
	_current_screen.connect("retry_level", _current_level_retry_level)
	_current_screen.connect("next_level", _current_level_next_level)
	_current_screen.connect("game_quit", _current_level_game_quit)

func _current_level_won():
	if _current_level_index == len(_LEVELS) - 1:
		return
	
	if _unlocked_levels[_current_level_index + 1]:
		return
	
	_unlocked_levels[_current_level_index + 1] = true
	_save_data()

func _current_level_retry_level():
	change_levels(_LEVELS[_current_level_index])

func _current_level_next_level():
	if _current_level_index == len(_LEVELS) - 1:
		load_level_select()
		return
	
	_current_level_index += 1
	change_levels(_LEVELS[_current_level_index])

func _current_level_game_quit():
	load_level_select()

func _main_menu_level_select_pressed():
	load_level_select()

func _main_menu_quit_pressed():
	game_ended.emit()

func _level_select_level_selected(index: int):
	_current_level_index = index
	change_levels(_LEVELS[index])

func _level_select_back_pressed():
	load_main_menu()
