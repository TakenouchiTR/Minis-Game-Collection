extends StaticBody2D

## How fast the obstacle rotates per second, in radians.
@export var rotation_speed := 0.0

@onready var _initial_speed := rotation_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	rotate(rotation_speed * delta)

func stop():
	rotation_speed = 0

func restart():
	rotation_speed = _initial_speed
