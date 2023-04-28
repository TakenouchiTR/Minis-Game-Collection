extends Path2D

@export var speed := 320.0

@onready var _initial_speed := speed

func _physics_process(delta):
	for path_follow in get_children():
		path_follow.progress += speed * delta

func stop():
	speed = 0
	for path_follow in get_children():
		for child in path_follow.get_children():
			child.stop()

func restart():
	speed = _initial_speed
	for path_follow in get_children():
		for child in path_follow.get_children():
			child.restart()
