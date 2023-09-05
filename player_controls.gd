extends Node3D


var water_height: float = 0
var max_engine_power: float = 1000
var max_rudder_rotation: float = deg_to_rad(60)
var rudder_rotation_speed: float = 3

var flow_speed: float = 5

var player: RigidBody3D
var engine_power: float = 0
var rudder_rotation: float = 0

func _ready() -> void:
	player = get_parent()
	
func _physics_process(delta: float) -> void:
	var forward_velocity = player.linear_velocity.dot(-player.global_transform.basis.z)
	var flow_percent = clamp(forward_velocity / flow_speed, 0, 1)

	DebugDraw.draw_ray_3d(player.global_position, -player.global_transform.basis.z, forward_velocity, Color.RED)
	
	var rudder_offset = (player.global_transform.basis.z * 2) - (player.global_transform.basis.y)
	var rudder_position = player.global_position + rudder_offset
	var rudder_direction = player.global_transform.basis.z.rotated(
		player.global_transform.basis.y,
		rudder_rotation
	)
	
	DebugDraw.draw_ray_3d(rudder_position, rudder_direction, 1, Color.WHITE)
	
	var is_rudder_in_water: bool = (player.global_position + rudder_offset).y < water_height
	
	if not is_rudder_in_water:
		return
	
	if Input.is_action_pressed("ui_up"):
		player.apply_force(-rudder_direction * max_engine_power, rudder_offset)
		
	if Input.is_action_pressed("ui_left"):
		rudder_rotation = move_toward(rudder_rotation, -max_rudder_rotation, rudder_rotation_speed * delta)
	elif Input.is_action_pressed("ui_right"):
		rudder_rotation = move_toward(rudder_rotation, max_rudder_rotation, rudder_rotation_speed * delta)
	else:
		rudder_rotation = move_toward(rudder_rotation, 0, rudder_rotation_speed * delta)
