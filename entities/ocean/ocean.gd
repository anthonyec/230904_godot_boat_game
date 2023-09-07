class_name Ocean
extends Node3D

@onready var simulation: SubViewport = $Simulation
@onready var plane: MeshInstance3D = $Plane

var plane_width: float = 50
var plane_height: float = 50

var last_call_time: int = 0
var image: Image
var image_size: Vector2 

func _process(delta: float) -> void:
	var now = Time.get_ticks_msec()
	var difference = now - last_call_time
	
	if difference > 250:
		image = simulation.get_texture().get_image()
		image_size = Vector2(float(image.get_width()), float(image.get_height()))
		last_call_time = Time.get_ticks_msec()
	
func get_height(at_position: Vector3) -> float:
	if not image:
		return 0
	
	var position_on_plane: Vector2 = Vector2(
		fmod(at_position.x + plane_width / 2, plane_width),
		fmod(at_position.z + plane_width / 2, plane_height)
	).abs()
	
	var percent_on_plane = Vector2(
		position_on_plane.x / plane_width,
		position_on_plane.y / plane_height,
	)
	
	return image.get_pixel(
		percent_on_plane.x * image_size.x,
		percent_on_plane.x * image_size.y
	).r
