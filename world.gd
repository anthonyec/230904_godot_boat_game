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

@export_group("Sea")
@export var wave_direction: Vector2 = Vector2.ZERO
@export var waves: WaveType = WaveType.NONE

var last_time: int = 0

func _ready() -> void:
	World.set_instance(self)

func _process(_delta: float) -> void:
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
		
static var instance: World
		
static func set_instance(world: World) -> void:
	instance = world
	
static func get_instance() -> World:
	return instance
	
func get_display_time() -> String:
	return str(hour).lpad(2, "0") + ":" + str(minute).lpad(2, "0")
	
func get_player() -> Node3D:
	return get_parent().get_node_or_null("Player")

func get_water_height(position: Vector3) -> float:
	return 0
