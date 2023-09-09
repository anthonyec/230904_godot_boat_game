extends Control

var parent: Node3D

func _ready() -> void:
	parent = get_parent()

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	var pos = parent.water.get_position_on_plane(parent.global_position)
	
	DebugDraw.set_text("get_position_on_plane", str(pos))
	
	var percent = parent.water.get_percent_on_plane(parent.global_position)
	var view_percent = parent.water.get_percent_on_plane(parent.global_position - parent.global_transform.basis.z * 5)
	
	draw_circle(size * percent, 3, Color.RED)
#	draw_line(size * percent, size * view_percent, Color.WHITE)
#	draw_rect(Rect2(size.x * percent.x, size.y * percent.y, 5, 5), Color.RED)
