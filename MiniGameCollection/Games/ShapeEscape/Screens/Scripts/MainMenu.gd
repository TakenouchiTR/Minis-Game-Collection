extends Control

signal quit_pressed
signal level_select_pressed

func _on_level_select_button_pressed():
	level_select_pressed.emit()

func _on_quit_button_pressed():
	quit_pressed.emit()
