extends Node3D

var water_height: float = 0
var max_engine_power: float = 1000
var max_rudder_rotation: float = deg_to_rad(60)
var rudder_rotation_speed: float = 3

var flow_speed: float = 5

var player: RigidBody3D
var engine_power: float = 0
var rudder_rotation: float = 0

var input_direction: float = 0
var throttle: float = 0

func _ready() -> void:
	player = get_parent()

func _process(delta: float) -> void:
	var debug_cam = get_parent().get_parent().get_node_or_null("DebugCam")
	
	if debug_cam and debug_cam.enabled:
		return
		
	input_direction = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	
	var throttle_direction = Input.get_action_strength("throttle_up") - Input.get_action_strength("throttle_down")
	throttle = clamp(throttle + throttle_direction * delta, -1, 1)
	
	if Input.is_action_just_pressed("throttle_reset"):
		throttle = 0
	
	if Debug.is_flag_enabled(Debug.Flag.PLAYER_CONTROLS):
		DebugDraw.set_text("input_direction", input_direction)
		DebugDraw.set_text("throttle", throttle)
	
func _physics_process(delta: float) -> void:
	var forward = -player.global_transform.basis.z
	var back = player.global_transform.basis.z
	var up = player.global_transform.basis.y
	var down = -player.global_transform.basis.y
	var right = player.global_transform.basis.x
	var left = -player.global_transform.basis.x
	
	var heading_velocity = player.linear_velocity.dot(forward)
	var side_velocity = player.linear_velocity.dot(right)
	
	var turn_percent = clamp(abs(heading_velocity) / 5, 0, 1)
	
	DebugDraw.draw_ray_3d(global_position, forward, heading_velocity, Color.BLUE)
	DebugDraw.draw_ray_3d(global_position, right, side_velocity, Color.RED)
		
	player.apply_central_force(forward * max_engine_power * throttle)
	player.apply_torque(up * max_engine_power * -input_direction * turn_percent)


