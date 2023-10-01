class_name Ocean
extends Node3D

const max_wave_height: float = 10
const max_wave_length: float = 100
const plane_origin: Vector2 = Vector2(50, 50)
const plane_grid_size: int = 6 # E.g 4x4 or 10x10

@export var wave_direction_1: Vector2 = Vector2(1, 0)
@export_range(0, max_wave_height) var wave_height: float = 1
@export_range(10, max_wave_length) var wave_length: float = 50

@onready var simulation: SubViewport = $Simulation
@onready var simulation_texture: ColorRect = $Simulation/Texture
@onready var plane: MeshInstance3D = $Repeater/Plane
@onready var repeater: Repeater = $Repeater as Repeater
@onready var big_plane: MeshInstance3D = $BigPlane

var plane_size: Vector2 = Vector2(512, 512)
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
	plane_size = Vector2(repeater.tile_size.x, repeater.tile_size.z)
	plane_material = plane.mesh.surface_get_material(0)
	simulation_material = simulation_texture.material

func _process(delta: float) -> void:
	update_shader_params(delta)
	update_simulation_image()
	
	big_plane.global_position = World.instance.get_player_position(true) + Vector3.DOWN
	
	repeater.debug = Flags.is_enabled(Flags.DEBUG_OCEAN_PLANES)

func update_shader_params(delta: float) -> void:
	plane_material.set_shader_parameter("MaxWaveHeight", max_wave_height)
	
	simulation_material.set_shader_parameter("WaveOffset1", wave_offset_1)
#	simulation_material.set_shader_parameter("WaveScale", max_wave_length / wave_length)
	simulation_material.set_shader_parameter("WaveHeightPercent", wave_height / max_wave_height)
	
	wave_offset_1 += wave_direction_1 * 0.01 * delta
	
	if Flags.is_enabled(Flags.DEBUG_OCEAN_SHADER_PARAMS):
		DebugDraw.set_text("WaveHeightPercent", simulation_material.get_shader_parameter("WaveHeightPercent"))
		DebugDraw.set_text("MaxWaveHeight", plane_material.get_shader_parameter("MaxWaveHeight"))

func update_simulation_image() -> void:
	if Flags.is_enabled(Flags.DEBUG_WATER_RENDER_TIME):
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

func get_position_on_plane(target: Vector3) -> Vector2:
	return Vector2(
		wrapf(target.x + (repeater.tile_size.x / 2), 0, plane_size.x),
		wrapf(target.z + (repeater.tile_size.z / 2), 0, plane_size.y)
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
