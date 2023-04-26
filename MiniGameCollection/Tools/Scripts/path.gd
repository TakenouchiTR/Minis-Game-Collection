@tool
extends Node2D

@export var points: Array[Vector2] = []
@export var include_origin: bool = true
@export var loop: bool = true
@export var point_radius: float = 5.0
@export var line_width: float = 2.0
@export var line_color: Color = Color(1, 1, 1, .5)
@export var point_color: Color = Color(1, 1, 1, .5)

var _distances: Array[float] = []
var _total_distance: float = 0

func _ready():
	if len(points) == 0:
		return
	
	var prev_position = Vector2.ZERO if include_origin else points[0]
	if include_origin:
		points.insert(0, Vector2.ZERO)
	
	if loop:
		points.append(points[0])
	
	for point in points:
		_distances.append(point.distance_to(prev_position))
		_total_distance += _distances[-1]
		prev_position = point

func _draw():
	#if not Engine.is_editor_hint():
	#	return
	
	if include_origin:
		draw_circle(Vector2.ZERO, point_radius, point_color)
	
	if len(points) == 0:
		return
	
	var prev_point: Vector2 = Vector2.ZERO if include_origin else points[0]
	var start_position = 0 if include_origin else 1
	
	for i in range(start_position, len(points)):
		draw_line(prev_point, points[i], line_color, line_width)
		prev_point = points[i]
	
	if loop:
		if include_origin:
			draw_line(points[-1], Vector2.ZERO, line_color, line_width)
		else:
			draw_line(points[-1], points[0], line_color, line_width)
	
	for point in points:
		draw_circle(point, point_radius, point_color)

func _process(delta):
	if not Engine.is_editor_hint():
		return
	
	queue_redraw()

func _normalize_distance(distance: float):
	return fmod(fmod(distance, _total_distance) + _total_distance, _total_distance)

func get_position_at_distance(distance: float):
	if loop:
		distance = _normalize_distance(distance)
	elif distance < 0:
		return points[0]
	elif distance > _total_distance:
		return points[-1]
		
	var index: int = 0
	var prev_point: Vector2 = Vector2.ZERO
	while distance > _distances[index] and index < len(points):
		prev_point = points[index]
		distance -= _distances[index]
		index += 1
	
	var position_difference: Vector2 = points[index] - prev_point
	var inner_distance_travelled: float = distance / _distances[index]
	
	return prev_point + position_difference * inner_distance_travelled

func goes_past_max_distance(distance: float):
	return not loop and distance > _total_distance

func get_distance_past_max_distance(distance: float):
	return distance - _total_distance if distance > _total_distance else 0

func get_percent_through_path(distance: float):
	if loop:
		distance = _normalize_distance(distance)
	else:
		distance = clamp(distance, 0, _total_distance)
	
	return distance / _total_distance
