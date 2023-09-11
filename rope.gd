class_name Rope
extends Node

@export var enabled: bool = true
@export var rigid_body_a: RigidBody3D
@export var rigid_body_b: RigidBody3D
@export var attachment_point_a: Node3D
@export var attachment_point_b: Node3D
@export var max_length: float = 10

# Use this to make the rope less "tight" causing objects to be pull harshly.
# Technically the value is how long for the object to reach the desired point.
@export var stretchiness: float = 5
@export var strength_multipler_a: float = 0.3
@export var strength_multipler_b: float = 1

func _process(_delta: float) -> void:
	if not enabled or not attachment_point_a or not attachment_point_b:
		return
		
	if Debug.is_flag_enabled(Debug.Flag.ROPE):
		DebugDraw.draw_line_3d(attachment_point_a.global_position, attachment_point_b.global_position, Color.BLACK)
	
	var point_a = attachment_point_a.global_position
	var point_b = attachment_point_b.global_position
	
	var offset_a = point_a - rigid_body_a.global_position
	var offset_b = point_b - rigid_body_b.global_position
	
	var direction_a_to_b = point_a.direction_to(point_b)
	var direction_b_to_a = point_b.direction_to(point_a)
	
	var desired_point_a = point_b + direction_b_to_a.normalized() * max_length
	var desired_point_b = point_a + direction_a_to_b.normalized() * max_length
	
	var distance = point_a.distance_to(point_b)
	
	# Point B force.
	if distance > max_length:
		var acceleration: float = distance / sqrt(stretchiness)
		
		# Probably can caclulate it like this, by having specfic numbers is 
		# easier to tune right now.
#		var strength_multipler: float = rigid_body_b.mass / rigid_body_a.mass
		
		var force_a: float = rigid_body_a.mass * acceleration * strength_multipler_a
		var force_b: float = rigid_body_b.mass * acceleration * strength_multipler_b
		
		rigid_body_a.apply_force(direction_a_to_b * force_a, offset_a)
		rigid_body_b.apply_force(direction_b_to_a * force_b, offset_b)
		
		if Debug.is_flag_enabled(Debug.Flag.ROPE):
			DebugDraw.draw_cube(desired_point_a, 0.2, Color.BLUE)
			DebugDraw.draw_ray_3d(point_a, direction_a_to_b, distance - max_length, Color.BLUE)
			
			DebugDraw.draw_cube(desired_point_b, 0.2, Color.RED)
			DebugDraw.draw_ray_3d(point_b, direction_b_to_a, distance - max_length, Color.RED)
