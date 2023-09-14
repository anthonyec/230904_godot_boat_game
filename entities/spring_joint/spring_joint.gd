class_name SpringJoint
extends Node

@export var enabled: bool = true
@export var rigid_body_a: RigidBody3D
@export var rigid_body_b: RigidBody3D
@export var attachment_point_a: Node3D
@export var attachment_point_b: Node3D
@export var max_length: float = 10
@export var stiffness: float = 80
@export var rigid: bool = false

func _process(_delta: float) -> void:
	if Flags.is_enabled(Flags.ROPE) and enabled:
		DebugDraw.draw_line_3d(
			attachment_point_a.global_position,
			attachment_point_b.global_position,
			Color.BLACK
		)

func _physics_process(delta: float) -> void:
	if not enabled:
		return
		
	if not rigid_body_a or not rigid_body_b or not attachment_point_a or not attachment_point_b:
		return
	
	var point_a = attachment_point_a.global_position
	var point_b = attachment_point_b.global_position
	
	var offset_a = point_a - rigid_body_a.global_position
	var offset_b = point_b - rigid_body_b.global_position
	
	var direction_a_to_b = point_a.direction_to(point_b)
	var direction_b_to_a = point_b.direction_to(point_a)
	
	var distance = point_a.distance_to(point_b)
	
	var spring_force = stiffness * (max_length - distance)
	var acceleration_a = spring_force / rigid_body_a.mass
	var acceleration_b = spring_force / rigid_body_b.mass
	var force_a = rigid_body_a.mass * acceleration_a
	var force_b = rigid_body_b.mass * acceleration_b
	
	if not rigid and distance > max_length:
		rigid_body_a.apply_force(direction_b_to_a * force_a, offset_a)
		rigid_body_b.apply_force(direction_a_to_b * force_b, offset_b)
