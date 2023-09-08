class_name Probe
extends Node3D

@export var float_force_multiplier: float = 1

var water_height: float = 0

func _ready() -> void:
	visible = false
	
func _process(delta: float) -> void:
	var water = get_parent().water
	var current_water_height = water.get_height(global_position)
	
	water_height = lerp(water_height, current_water_height, delta * 5)
	
	var water_height_position = Vector3(global_position.x, current_water_height, global_position.z)
	
	DebugDraw.draw_cube(global_position, 0.05, Color.BLACK)
	DebugDraw.draw_cube(water_height_position, 0.1, Color.BLUE)
	DebugDraw.draw_cube(water_height_position, 0.2, Color.RED)
