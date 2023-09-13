class_name Ocean
extends Node3D

const max_wave_height: float = 10
const plane_size: Vector2 = Vector2(100, 100)
const plane_origin: Vector2 = Vector2(50, 50)
const plane_grid_size: int = 6 # E.g 4x4 or 10x10

@export var wave_direction_1: Vector2 = Vector2(1, 0)
@export var wave_height_1: float = 1

@onready var simulation: SubViewport = $Simulation
@onready var simulation_texture: ColorRect = $Simulation/Texture
@onready var plane: MeshInstance3D = $Plane

var time_to_render_image: int = 0
var last_call_time: int = 0
var image: Image
var image_size: Vector2 
var plane_material: ShaderMaterial
var simulation_material: ShaderMaterial
var planes: Array[MeshInstance3D] = []

var wave_offset_1: Vector2

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _ready() -> void:
	# Spawn plane pool for moving them around to simulate infinite planes.
	var number_of_planes = plane_grid_size * plane_grid_size
	
	for index in number_of_planes:
		var duplicated_plane = plane.duplicate()
		add_child(duplicated_plane)
		planes.append(duplicated_plane)
		
	plane_material = plane.mesh.surface_get_material(0)
	simulation_material = simulation_texture.material
	
	# Remove the original plane used to duplicate.
	remove_child(plane)

func _process(delta: float) -> void:
	update_shader_params(delta)
	update_simulation_image()
	update_infinite_planes()

func update_shader_params(delta: float) -> void:
	plane_material.set_shader_parameter("MaxWaveHeight", max_wave_height)
	
	simulation_material.set_shader_parameter("WaveOffset1", wave_offset_1)
	simulation_material.set_shader_parameter("WaveHeightPercent", wave_height_1 / max_wave_height)
	
	wave_offset_1 += wave_direction_1 * 0.1 * delta
	
	if Debug.is_flag_enabled(Debug.Flag.OCEAN_SHADER_PARAMS):
		DebugDraw.set_text("WaveHeightPercent", simulation_material.get_shader_parameter("WaveHeightPercent"))
		DebugDraw.set_text("MaxWaveHeight", plane_material.get_shader_parameter("MaxWaveHeight"))

func update_simulation_image() -> void:
	if Debug.is_flag_enabled(Debug.Flag.WATER_RENDER_TIME):
		DebugDraw.set_text("water image time: ", str(time_to_render_image) + "ms")
	
	# Update texture image cache.
	var now = Time.get_ticks_msec()
	var difference = now - last_call_time
	
	# TODO: Maybe make this time dynamic based on the average time the GPU 
	# takes to send back the image?
	if difference > 150:
		var time_before_image = Time.get_ticks_msec()
		image = simulation.get_texture().get_image()
		time_to_render_image = Time.get_ticks_msec() - time_before_image
		
		image_size = Vector2(float(image.get_width()), float(image.get_height()))
		last_call_time = Time.get_ticks_msec()

func update_infinite_planes() -> void:
	var camera = get_viewport().get_camera_3d()
	
	var nearest_plane_position: Vector3 = Vector3(
		# Adding the origin surrounds the player with even number of planes.
		(round(camera.global_position.x / plane_size.x) * plane_size.x) + plane_origin.x,
		global_position.y,
		(round(camera.global_position.z / plane_size.y) * plane_size.y) + plane_origin.x,
	)
	
	if Debug.is_flag_enabled(Debug.Flag.OCEAN_PLANES):
		DebugDraw.draw_box(nearest_plane_position, Vector3(1, 20, 1), Color.RED)
	
	var index: int = 0
		
	for x in plane_grid_size:
		for z in plane_grid_size:
			var duplicate_position = Vector3(
				(nearest_plane_position.x + plane_size.x * x) - (plane_size.x / 2 * plane_grid_size),
				0,
				(nearest_plane_position.z + plane_size.y * z) - (plane_size.y / 2 * plane_grid_size)
			)
			
			planes[index].global_position = duplicate_position
			index += 1
			
			if Debug.is_flag_enabled(Debug.Flag.OCEAN_PLANES):
				DebugDraw.draw_ray_3d(duplicate_position, Vector3.UP, 10, Color.BLUE)
				DebugDraw.draw_box(duplicate_position + Vector3.UP * 25, Vector3(plane_size.x, 50, plane_size.y), Color.BLACK)

func get_position_on_plane(target: Vector3) -> Vector2:
	# Note if ` + plane_origin.x` is removed from plane positioning, it needs to
	# added here like `target.x + plane_origin.x`. This keeps them in sync.
	return Vector2(
		wrapf(target.x, 0, plane_size.x),
		wrapf(target.z, 0, plane_size.y)
	)

func get_percent_on_plane(other_position: Vector3) -> Vector2:
	var position_on_plane = get_position_on_plane(other_position)
	return position_on_plane / plane_size

func get_height(at_position: Vector3) -> float:
	if not image:
		return 0
	
	var percent_on_plane = get_percent_on_plane(at_position)
	
	var sample_position = percent_on_plane * image_size
	var color = image.get_pixel(sample_position.x, sample_position.y)
	
	# Only sample the red channel, all colors the same because it's greyscale.
	return color.r * max_wave_height
