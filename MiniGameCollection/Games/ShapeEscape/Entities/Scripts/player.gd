extends CharacterBody2D

signal hit_wall

@export var speed := 320.0

@onready var _initial_speed := speed

func stop():
	speed = 0
	velocity = Vector2.ZERO

func restart():
	speed = _initial_speed

func _physics_process(_delta):
	if is_on_wall():
		hit_wall.emit()
		queue_free()
		return
	
	var x_direction := Input.get_axis("move_left", "move_right")
	var y_direction := Input.get_axis("move_up", "move_down")
	
	velocity = Vector2(x_direction, y_direction).normalized() * speed

	move_and_slide()
