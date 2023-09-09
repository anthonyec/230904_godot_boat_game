extends Control

var parent: Node3D

func _ready() -> void:
	parent = get_parent()

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	var percent = parent.water.get_percent_on_plane(parent.global_position)
	draw_circle(size * percent, 3, Color.RED)
