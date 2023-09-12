@tool
extends Control

func _process(_delta: float) -> void:
	queue_redraw()
	
func draw_arrow(start: Vector2, end: Vector2, head_size: float, head_angle: float, color: Color, width: float = 1.0) -> void:
	var arrow_head_angle = deg_to_rad(head_angle)
	var arrow_head_bottom = end.direction_to(start).normalized() * head_size
		
	draw_line(start, end, color, width)
	draw_line(end, end + arrow_head_bottom.rotated(arrow_head_angle), color, width)
	draw_line(end, end + arrow_head_bottom.rotated(-arrow_head_angle), color, width)

func draw_compass(origin: Vector2, radius: float, padding: float, color: Color) -> void:
	var camera = get_parent().get_viewport().get_camera_3d()
	var camera_rotation = -camera.global_rotation.y

	var start = Vector2(
		origin.x + (sin(camera_rotation) * (radius - padding)),
		origin.y + (cos(camera_rotation) * (radius - padding))
	)

	var end = Vector2(
		origin.x - (sin(camera_rotation) * (radius - padding)),
		origin.y - (cos(camera_rotation) * (radius - padding))
	)
	
	draw_arc(origin, radius, 0, PI * 2, 9, color, 2)
	draw_arrow(start, end, 15, 45, color, 2)
	
func _draw() -> void:
	var diameter = minf(size.x, size.y)
	draw_compass(size / 2, diameter / 2, 15, Color.BLUE)
