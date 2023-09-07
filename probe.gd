class_name Probe
extends Node3D

@export var float_force_multiplier: float = 1

var water_height: float = 0

func _ready() -> void:
	visible = false
	
func _process(delta: float) -> void:
	var water = get_parent().water
	
	water_height = lerp(water_height, water.get_height(global_position), delta * 5)
	
	DebugDraw.draw_cube(global_position, 0.2, Color.BLACK)
	DebugDraw.draw_cube(
		Vector3(global_position.x, water_height, global_position.z),
		0.2,
		Color.RED
	)
