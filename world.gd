class_name World
extends Node

enum RainType {
	NONE,
	DRIZZLE,
	LIGHT,
	HEAVY
}

enum WindType {
	NONE,
	SLOW,
	STEADY,
	QUICK,
	RAPID
}

# Based on: https://www.metoffice.gov.uk/weather/guides/coast-and-sea/glossary
enum WaveType {
	NONE,
	SMOOTH,
	MODERATE,
	ROUGH,
	VERY_ROUGH,
	HIGH,
	VERY_HIGH,
	PHENOMENAL
}

enum FogType {
	NONE,
	MIST,
	MILD,
	DENSE
}

enum LightningType {
	NONE,
	LIGHT,
	HEAVY,
}

@export_group("Clock")
@export_range(0, 23) var hour: int = 8
@export_range(0, 59) var minute: int = 0

@export_group("Weather")
@export var wind_direction: Vector2 = Vector2.ZERO
@export var wind: WindType = WindType.NONE

@export var rain: RainType = RainType.NONE
@export var fog: FogType = FogType.NONE
@export var lightning: LightningType = LightningType.NONE

@export_group("Ocean")
@export var wave_direction: Vector2 = Vector2.ZERO
@export var wave_type: WaveType = WaveType.NONE

var player: Node3D
var ocean: Ocean

var last_time: int = 0

static var instance: World

func _ready() -> void:
	if instance != null:
		push_error("A World instance already exists in this scene, overriding previous")
		
	instance = self
	player = get_parent().get_node("Player")
	ocean = get_parent().get_node("Ocean")

func _process(delta: float) -> void:
	var target_wave_height: float
	
	match wave_type:
		WaveType.NONE: target_wave_height = 0
		WaveType.SMOOTH: target_wave_height = 0.5
		WaveType.MODERATE: target_wave_height = 1.5
		WaveType.ROUGH: target_wave_height = 2
		WaveType.VERY_ROUGH: target_wave_height = 3
		WaveType.HIGH: target_wave_height = 5
		WaveType.VERY_HIGH: target_wave_height = 8
		WaveType.PHENOMENAL: target_wave_height = 10
			
	ocean.wave_height_1 = move_toward(ocean.wave_height_1, target_wave_height, delta)
	
	DebugDraw.set_text("target_wave_height", target_wave_height)
	DebugDraw.set_text("ocean.wave_height_1", ocean.wave_height_1)
	
#	ocean.wave_direction_1 = wave_direction
#	ocean.wave_direction_2 = wave_direction
#	ocean.wave_direction_3 = wave_direction
	
	update_time()
	
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
		
	if Debug.is_flag_enabled(Debug.Flag.TIME):
		DebugDraw.set_text("time", get_display_time())
	
func get_display_time() -> String:
	return str(hour).lpad(2, "0") + ":" + str(minute).lpad(2, "0")
	
func get_player() -> Node3D:
	return player

func get_water_height(position: Vector3) -> float:
	return ocean.get_height(position)
