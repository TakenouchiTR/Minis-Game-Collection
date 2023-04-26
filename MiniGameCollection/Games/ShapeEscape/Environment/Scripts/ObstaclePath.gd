extends Path2D

@export var speed = 320

@onready var _path_follow: PathFollow2D = $PathFollow2D

func _physics_process(delta):
	_path_follow.progress += speed * delta

func stop():
	speed = 0
	for child in _path_follow.get_children():
		child.stop()
