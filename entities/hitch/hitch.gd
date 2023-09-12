class_name Hitch
extends Area3D

var spring_joint_scene: PackedScene = preload("res://entities/spring_joint/spring_joint.tscn")

var nearby_hitch: Hitch = null
var attached_to: Hitch = null

func attach_to_nearby() -> void:
	if attached_to != null:
		return
		
	if not nearby_hitch:
		push_warning("No nearby hitches")
		return
		
	if not (get_parent() is RigidBody3D):
		push_warning("Parent needs to be a RigidBody3D")
		return
		
	if not (nearby_hitch.get_parent() is RigidBody3D):
		push_warning("Other hitch needs to have a parent RigidBody3D")
		return
		
	var attachment_points = get_attachment_points()
	var other_attachment_points = nearby_hitch.get_attachment_points()
	
	for index in attachment_points.size():
		var point = attachment_points[index]
		var other_point = other_attachment_points[index] if index < other_attachment_points.size() else other_attachment_points[-1]
		
		var spring = spring_joint_scene.instantiate() as SpringJoint
		
		spring.rigid_body_a = get_parent()
		spring.rigid_body_b = nearby_hitch.get_parent()
		spring.attachment_point_a = point
		spring.attachment_point_b = other_point
		
		add_child(spring)
	
	attached_to = nearby_hitch
	
func detach_from_nearby() -> void:
	for spring in get_spring_joints():
		remove_child(spring)
		
	attached_to = null
	
func is_attached() -> bool:
	return attached_to != null
	
func toggle_nearby_attachment() -> void:
	if is_attached():
		detach_from_nearby()
	else:
		attach_to_nearby()

func get_spring_joints() -> Array[SpringJoint]:
	var springs: Array[SpringJoint] = []
	
	for child in get_children(false):
		if child is SpringJoint:
			springs.append(child)
		
	return springs

func get_attachment_points() -> Array[Marker3D]:
	var points: Array[Marker3D] = []
	
	for child in get_children(false):
		if child is Marker3D:
			points.append(child)
		
	return points

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("hitch") and nearby_hitch == null:
		nearby_hitch = area

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("hitch") and nearby_hitch == area:
		nearby_hitch = null
