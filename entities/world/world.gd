class_name World
extends Node

static var instance: World

# Based on: https://www.metoffice.gov.uk/weather/guides/coast-and-sea/glossary
enum WaveHeight {
	NONE,
	SMOOTH,
	MODERATE,
	ROUGH,
	VERY_ROUGH,
	HIGH,
	VERY_HIGH,
	PHENOMENAL
}

enum WaveLength {
	SMALL,
	MEDIUM,
	LARGE,
	VERY_LARGE
}

@export_group("Clock")
@export_range(0, 23) var hour: int = 8
@export_range(0, 59) var minute: int = 0

@export_group("Ocean")
@export var wave_direction: Vector2 = Vector2.ZERO
@export var wave_height: WaveHeight = WaveHeight.MODERATE
@export var wave_length: WaveLength = WaveLength.MEDIUM

var player: Node3D
var ocean: Ocean

var last_time: int = 0

func _ready() -> void:
	if instance != null:
		push_error("A World instance already exists in this scene, overriding previous")
		
	instance = self
	player = get_parent().get_node("Player")
	ocean = get_parent().get_node("Ocean")

func _process(delta: float) -> void:
	update_time()
	
	var target_wave_height: float
	var target_wave_length: float
	
	match wave_height:
		WaveHeight.NONE:
			target_wave_height = 0
		WaveHeight.SMOOTH:
			target_wave_height = 0.5
		WaveHeight.MODERATE:
			target_wave_height = 2
		WaveHeight.ROUGH:
			target_wave_height = 3
		WaveHeight.VERY_ROUGH:
			target_wave_height = 4
		WaveHeight.HIGH:
			target_wave_height = 5
		WaveHeight.VERY_HIGH:
			target_wave_height = 8
		WaveHeight.PHENOMENAL:
			target_wave_height = 10
			
	match wave_length:
		WaveLength.SMALL:
			target_wave_length = 20
		WaveLength.MEDIUM:
			target_wave_length = 50
		WaveLength.LARGE:
			target_wave_length = 70
		WaveLength.VERY_LARGE:
			target_wave_length = 100
		
	ocean.wave_height = move_toward(ocean.wave_height, target_wave_height, delta)
	ocean.wave_length = move_toward(ocean.wave_length, target_wave_length, delta)
	
func update_time() -> void:
	var now = Time.get_ticks_msec()
	
	if now - last_time > 1000:
		minute += 1
		last_time = now
	
	if minute > 59:
		hour += 1
		minute = 0
		
	if hour > 23:
		hour = 0
		minute = 0
		
	if Flags.is_enabled(Flags.DEBUG_TIME):
		DebugDraw.set_text("time", get_display_time())
	
func get_display_time() -> String:
	return str(hour).lpad(2, "0") + ":" + str(minute).lpad(2, "0")
	
func get_time_percent() -> float:
	return 0
	
func get_player() -> Node3D:
	return player

func get_water_height(position: Vector3) -> float:
	return ocean.get_height(position)
