class_name DistantWeatherEffect
extends Node3D

@onready var particles: CPUParticles3D = $DistantRainParticles

func _process(delta: float) -> void:
	var preciptation = World.instance.get_precipitation(global_position)
	
	if preciptation > 0.5:
#		DebugDraw.draw_cube(global_position, 300, Color.BLUE)
		particles.emitting = true
	else:
		particles.emitting = false
