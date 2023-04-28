extends Node2D

signal level_won
signal retry_level
signal next_level
signal game_quit

@onready var _player := $Player
@onready var _obstacles := $Obstacles
@onready var _foreground_obstacles := $ForegroundObstacles
@onready var _level_won_canvas := $LevelWonCanvas
@onready var _game_over_canvas := $GameOverCanvas

func _stop_movement():
	_player.stop()
	var nodes := _obstacles.get_children() + _foreground_obstacles.get_children()
	while nodes:
		var node = nodes.pop_front()
		if node.has_method("stop"):
			node.stop()
		else:
			nodes += node.get_children()

func _on_win_area_area_entered(_area):
	_stop_movement()
	level_won.emit()
	_level_won_canvas.visible = true

func _on_player_hit_wall():
	_stop_movement()
	_game_over_canvas.visible = true

func _on_quit_button_pressed():
	game_quit.emit()

func _on_retry_button_pressed():
	retry_level.emit()

func _on_continue_button_pressed():
	next_level.emit()
