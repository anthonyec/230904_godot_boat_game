class_name GameplayCamera
extends Node3D

@export var target: Node3D

@export var distance: float = 15
@export var speed: float = 5

@onready var rig: Node3D = %Rig
@onready var camera: Camera3D = %Camera3D

var mouse_relative: Vector2
	
func _physics_process(delta: float) -> void:
	camera.position.z = distance

	global_transform.origin = global_transform.origin.lerp(
		target.global_position, 
		delta * 10
	)
	
	rotation.y -= deg_to_rad(mouse_relative.x * 0.5)
	rig.rotation.x -= deg_to_rad(mouse_relative.y * 0.5)
	
	rig.rotation.x = clamp(rig.rotation.x, deg_to_rad(-80), deg_to_rad(-5))	
	mouse_relative = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_relative = event.relative

