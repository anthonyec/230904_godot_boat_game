class_name Ocean
extends Node3D

@onready var simulation: SubViewport = $Simulation

func get_height(position: Vector3) -> float:
#	var texture = simulation.get_texture()
#	var image = texture.get_image() # TOO SLOW
	
#	return image.get_pixel(10, 10).r
	return 0
