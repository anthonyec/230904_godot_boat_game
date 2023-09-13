@tool
extends Control

var font: FontFile = preload("res://ui/hershey_noailles_futura_simplex_regular.ttf")

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	pass
