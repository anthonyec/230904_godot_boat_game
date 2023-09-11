extends Area3D

func _on_body_entered(body: Node3D) -> void:
	var bell = get_parent().get_node("RigidBody3D")
	var velocity = bell.linear_velocity.length()
	var volume = remap(velocity, 1, 5, -15, -6)
	var params = SFX.Parameters.new()
	
	params.pitch_scale = 1.7
	params.max_distance = 150
	params.volume_db = volume

	SFX.play_attached_to_node("fog_bell_02", get_parent(), params)
