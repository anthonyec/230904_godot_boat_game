extends Node3D

@onready var repeater: Repeater = $Repeater as Repeater

var particle_amount: float = 1

func _ready() -> void:
	repeater.viewer = World.instance.get_player()
	
func _process(delta: float) -> void:
	var player = World.instance.get_player()
	var preciptation = World.instance.get_precipitation(player.global_position)
	
	if preciptation == 0 or particle_amount < 5:
		# TODO: Doesn't do anything at the moment.
		repeater.stop()
	
	var target_particle_amount = remap(preciptation, 0, 1, 1, 500)
	
	particle_amount = lerp(particle_amount, target_particle_amount, delta * 5)
	DebugDraw.set_text("particle_amount", particle_amount)
	
	for child in repeater.get_duplicates():
		var particles = child as CPUParticles3D
		particles.amount = clamp(particle_amount, 1, 500)
