extends CharacterBody2D

signal hit_wall

@export var speed: float = 320

func _physics_process(_delta):
	if is_on_wall():
		hit_wall.emit()
		queue_free()
	
	var x_direction = Input.get_axis("move_left", "move_right")
	var y_direction = Input.get_axis("move_up", "move_down")
	
	if x_direction:
		velocity.x = x_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if y_direction:
		velocity.y = y_direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()
