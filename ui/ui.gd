@tool
extends Control

var font: FontFile = preload("res://ui/hershey_noailles_futura_simplex_regular.ttf")

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	pass

func draw_arrow(control: Control, start: Vector2, end: Vector2, head_size: float, head_angle: float, color: Color, width: float = 1.0) -> void:
	var arrow_head_angle = deg_to_rad(head_angle)
	var arrow_head_bottom = end.direction_to(start).normalized() * head_size
		
	control.draw_line(start, end, color, width)
	control.draw_line(end, end + arrow_head_bottom.rotated(arrow_head_angle), color, width)
	control.draw_line(end, end + arrow_head_bottom.rotated(-arrow_head_angle), color, width)
