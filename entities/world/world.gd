class_name World
extends Node

signal minute_tick
signal hour_tick

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

var precipitation_grid = Grid.new()

#var precipitation_grid = Grid.new([
#	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#	[0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
#	[0, 0, 1, 50, 1, 1, 0, 0, 0, 0],
#	[0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
#	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#	[0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
#	[0, 1, 2, 1, 0, 1, 1, 1, 0, 0],
#	[0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
#	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
#])

#var precipitation_grid = Grid.new([
#	[1, 2, 3],
#	[4, 5, 6],
#	[7, 8, 9],
#])

#var precipitation_grid = Grid.new([
#	[0, 0, 0],
#	[0, 5, 0],
#	[0, 0, 0],
#])

#var precipitation_grid = Grid.new([
#	[1, 2, 3, 4],
#	[5, 6, 7, 8],
#	[9, 10, 11, 12],
#])

#var precipitation_grid = Grid.new([
#	[0, 0, 0, 0],
#	[0, 5, 0, 0],
#	[0, 0, 0, 0],
#])


func _ready() -> void:
	if instance != null:
		push_error("A World instance already exists in this scene, overriding previous")
		
	instance = self
	player = get_parent().get_node("Player")
	ocean = get_parent().get_node("Ocean")
	
	precipitation_grid.create_and_fill(30, 30, 0)
	precipitation_grid.set_tile_at_row_column(50, 50, 1000)
	
	minute_tick.connect(_on_minute_tick)

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
		minute_tick.emit()
	
	if minute > 59:
		hour += 1
		minute = 0
		
	if hour > 23:
		hour = 0
		minute = 0
		hour_tick.emit()
		
	if Flags.is_enabled(Flags.DEBUG_TIME):
		DebugDraw.set_text("time", get_display_time())

func _on_minute_tick() -> void:
	var energy_loss_per_tile: float = 0.5 / 8
	
	precipitation_grid.simulate_step(func(previous_grid: Grid, next_grid: Grid, row: int, column: int):
		var neighbour_values = previous_grid.get_neighbours_at_row_column(row, column)
		var sum: float = neighbour_values.reduce(func(accum, value): return accum + value, 0)
		var average: float = sum / neighbour_values.size()
		
		next_grid.set_tile_at_row_column(row, column, average * 0.95)
	)

	
func get_display_time() -> String:
	return str(hour).lpad(2, "0") + ":" + str(minute).lpad(2, "0")
	
func get_time_percent() -> float:
	return 0
	
func get_player() -> Node3D:
	return player

func get_water_height(position: Vector3) -> float:
	return ocean.get_height(position)
	
func get_precipitation(position: Vector3) -> int:
	var a = precipitation_grid.get_tile_at_position(position)
	var b = precipitation_grid.get_row_column_at_position(position)
#	print(b)
	return 0
