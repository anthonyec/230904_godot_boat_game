class_name Ocean
extends Node3D

@export var max_wave_height: float = 2
@export var wave_direction_1: Vector2 = Vector2(0.05, 0.05)
@export var wave_direction_2: Vector2 = Vector2(0.05, -0.05)

@onready var simulation: SubViewport = $Simulation
@onready var simulation_texture: ColorRect = $Simulation/Texture
@onready var plane: MeshInstance3D = $Plane

var plane_width: float = 100
var plane_height: float = 100
var max_planes: int = 6 # Even numbers work best for even spread around camera.

var time: float = 0
var last_call_time: int = 0
var image: Image
var image_size: Vector2 
var plane_material: ShaderMaterial
var simulation_material: ShaderMaterial
var planes: Array[MeshInstance3D] = []

func _ready() -> void:
	# Spawn plane pool for moving them around to simulate infinite planes.
	var number_of_planes = max_planes * max_planes
	
	for index in number_of_planes:
		var duplicated_plane = plane.duplicate()
		add_child(duplicated_plane)
		planes.append(duplicated_plane)
		
	plane_material = plane.mesh.surface_get_material(0)
	simulation_material = simulation_texture.material

func _process(delta: float) -> void:
	time += delta
	
	# Update texture image cache.
	var now = Time.get_ticks_msec()
	var difference = now - last_call_time
	
	# TODO: Maybe make this time dynamic based on the average time the GPU 
	# takes to send back the image?
	if difference > 150:
		image = simulation.get_texture().get_image()
		image_size = Vector2(float(image.get_width()), float(image.get_height()))
		last_call_time = Time.get_ticks_msec()
	
	# Set wave shader parameters.
	plane_material.set_shader_parameter("MaxWaveHeight", max_wave_height)
	simulation_material.set_shader_parameter("Time", time)
	simulation_material.set_shader_parameter("WaveDirection1", wave_direction_1)
	simulation_material.set_shader_parameter("WaveDirection2", wave_direction_2)
	
	# Infinite planes.
	var camera = get_viewport().get_camera_3d()
	
	var nearest_plane_position: Vector3 = Vector3(
		round(camera.global_position.x / plane_width) * plane_width,
		global_position.y,
		round(camera.global_position.z / plane_height) * plane_height,
	)
	
	var index: int = 0
	
	for x in range(-max_planes / 2, max_planes / 2):
		for z in range(-max_planes / 2, max_planes / 2):
			var surrounding_plane_position = nearest_plane_position - Vector3(plane_width * x, 0, plane_height * z)
			
			planes[index].global_position = surrounding_plane_position
			index += 1
		
func get_position_on_plane(other_position: Vector3) -> Vector2:
	return Vector2(
		fmod(other_position.x + plane_width / 2, plane_width),
		fmod(other_position.z + plane_width / 2, plane_height)
	).abs()
	
func get_percent_on_plane(other_position: Vector3) -> Vector2:
	var position_on_plane = get_position_on_plane(other_position)
	
	return Vector2(
		position_on_plane.x / plane_width,
		position_on_plane.y / plane_height,
	)
	
func get_height(at_position: Vector3) -> float:
	if not image:
		return 0
	
	var percent_on_plane = get_percent_on_plane(at_position)
	
	var color = image.get_pixel(
		percent_on_plane.x * image_size.x,
		percent_on_plane.y * image_size.y
	).r
	
	return color * max_wave_height
