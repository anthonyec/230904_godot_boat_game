extends Node3D

@export var engine_marker: Marker3D

@onready var hitch_back: Hitch = $"../HitchBack" as Hitch

var max_engine_power: float = 15000
var max_turn_power: float = 16000
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
		
	if Input.is_action_just_pressed("toggle_attachment"):
		hitch_back.toggle_nearby_attachment()
	
	if Flags.is_enabled(Flags.DEBUG_PLAYER_CONTROLS):
		DebugDraw.set_text("position", global_position.round())
		DebugDraw.set_text("input_direction", input_direction)
		DebugDraw.set_text("throttle", throttle)
		
		var wind = World.instance.get_wind(global_position)
		
		DebugDraw.draw_ray_3d(
			global_position + Vector3.UP * 10,
			wind,
			wind.length() * 10,
			Color.RED
		)
	
	if Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS):
		DebugDraw.set_text("precipitation", World.instance.get_precipitation(global_position))
		DebugDraw.set_text("precipitation r/c", World.instance.precipitation_grid.get_coordinate_at_world_position(global_position))
		
	
func _physics_process(delta: float) -> void:
	var forward = -player.global_transform.basis.z
	var back = player.global_transform.basis.z
	var up = player.global_transform.basis.y
	var down = -player.global_transform.basis.y
	var right = player.global_transform.basis.x
	var left = -player.global_transform.basis.x
	
	var wind = World.instance.get_wind(global_position)
	var heading_velocity = player.linear_velocity.dot(forward)
	var side_velocity = player.linear_velocity.dot(right)
	var turn_percent = clamp(abs(heading_velocity) / 5, 0, 1)
	
	var is_engined_submerged = engine_marker.global_position.y < World.instance.get_water_height(engine_marker.global_position)
	
	player.apply_central_force(wind * 1500)
	
	if is_engined_submerged:
		player.apply_central_force(forward * max_engine_power * throttle)
		player.apply_torque(up * max_turn_power * -input_direction * turn_percent)
	
	if Flags.is_enabled(Flags.DEBUG_PLAYER_CONTROLS):
		DebugDraw.set_text("position", global_position.round())
		DebugDraw.set_text("speed (kph)", heading_velocity)
		
		if is_engined_submerged:
			DebugDraw.draw_cube(engine_marker.global_position, 0.5, Color.RED)
		else:
			DebugDraw.draw_cube(engine_marker.global_position, 0.5, Color.BLACK)
			
		DebugDraw.draw_ray_3d(global_position, forward, heading_velocity, Color.BLUE)
		DebugDraw.draw_ray_3d(global_position, right, side_velocity, Color.RED)


