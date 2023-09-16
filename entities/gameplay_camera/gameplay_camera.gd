class_name GameplayCamera
extends Node3D

@export var current: bool = true
@export var target: Node3D
@export var distance: float = 15
@export var offset: Vector3
@export var speed: float = 5

@onready var rig: Node3D = %Rig
@onready var camera: Camera3D = %Camera3D

var mouse_relative: Vector2
var pitch_angle: float = 0

func _process(_delta: float) -> void:
	camera.current = current
	
func _physics_process(delta: float) -> void:
	global_transform.origin = global_transform.origin.lerp(
		target.global_position + offset, 
		delta * 10
	)
	
	rotation.y -= deg_to_rad(mouse_relative.x * 0.5)
	
	pitch_angle -= deg_to_rad(mouse_relative.y * 0.5)
	pitch_angle = clamp(pitch_angle, deg_to_rad(-80), deg_to_rad(80))
	
	var target_distance = distance
	
	if pitch_angle > deg_to_rad(5):
		var angle_offset = pitch_angle - deg_to_rad(5)
		camera.rotation.x = angle_offset / 2
		
		var percent = remap(pitch_angle, deg_to_rad(5), deg_to_rad(80), 0, 1)
		target_distance = target_distance - (5 * percent)
	else:
		camera.rotation.x = 0
		rig.rotation.x = pitch_angle
	
	camera.position.z = target_distance
	
	# Reset relative motion.
	mouse_relative = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_relative = event.relative

