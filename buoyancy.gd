extends RigidBody3D

@export var float_force: float = 5

var water_height: float = 0
var water_drag: float = 0.05
var water_angular_drag: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var submerged_percent: float = 0

func get_probes() -> Array[Probe]:
	var probes: Array[Probe] = []
	
	for child in get_children():
		probes.append(child as Probe)
		
	return probes

func _physics_process(delta: float) -> void:
	var probes = get_probes()
	var submerged_count: int = 0
	
	for probe in get_probes():
		if not probe:
			continue

		var depth = water_height - probe.global_position.y
		var multiplier = probe.float_force_multiplier
		var force = Vector3.UP * float_force * gravity * depth * multiplier
		
		if depth > 0:
			apply_force(force, probe.global_position - global_position)
			submerged_count += 1
			
	submerged_percent = float(submerged_count) / float(probes.size())

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity *=  1 - (water_drag * submerged_percent)
	state.angular_velocity *= 1 - (water_angular_drag * submerged_percent)
