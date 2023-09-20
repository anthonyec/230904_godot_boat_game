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
var last_step_duration: int = 0

var precipitation_grid = Grid.new(20, 20)

func _ready() -> void:
	if instance != null:
		push_error("A World instance already exists in this scene, overriding previous")
		
	instance = self
	player = get_parent().get_node("Player")
	ocean = get_parent().get_node("Ocean")
	
	precipitation_grid.set_cell_at_coordinate(2, 2, 10)
	precipitation_grid.set_cell_at_coordinate(15, 15, 10)
	
#	minute_tick.connect(step_grid_simulation)
#	hour_tick.connect(step_grid_simulation)
	
	step_grid_simulation()
	step_grid_simulation()
	

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
	
	if Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS):
		DebugDraw.set_text("sim step time (ms)", last_step_duration)
	
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

func step_grid_simulation() -> void:
	var energy_loss_per_tile: float = 0.5 / 8
	
	var now = Time.get_ticks_msec()
	
	precipitation_grid.step(func(previous_grid: Grid, next_grid: Grid, x: int, y: int):
		# Diffusion
		var neighbour_values = previous_grid.get_neihbours_at_coordinate(x, y)
		var sum: float = neighbour_values.reduce(func(accum, value): return accum + value, 0)
		var average: float = sum / neighbour_values.size()
		
		if average < 0.1:
			average = 0
			
		next_grid.set_cell_at_coordinate(x, y, average * 0.95)
		
		# Advection
#		var wind_direction = wind_grid.get_neighbours_at_row_column(row, column)
#		var next_row_column = [row, column + 1] # Todo: Calculate this from vector2.
		
#		var center_value = previous_grid.get_tile_at_row_column(row, column)
#		var right_value = previous_grid.get_tile_at_row_column(row, column + 1)
		
#		if center_value != 0 and right_value == 0:
#			next_grid.set_tile_at_row_column(row, column, float(center_value) - 0.5)
#			next_grid.set_tile_at_row_column(row, column + 1, float(right_value) + 0.5)
#			next_grid.set_tile_at_row_column(row, column + 2, center_value)
	)
	
	var duration = Time.get_ticks_msec() - now
	last_step_duration = duration

	
func get_display_time() -> String:
	return str(hour).lpad(2, "0") + ":" + str(minute).lpad(2, "0")
	
func get_time_percent() -> float:
	return 0
	
func get_player() -> Node3D:
	return player
	
func get_camera() -> Camera3D:
	return get_viewport().get_camera_3d()

func get_water_height(position: Vector3) -> float:
	return ocean.get_height(position)
	
func get_precipitation(position: Vector3) -> float:
	return precipitation_grid.get_cell_at_world_position(position)
	
func is_player_surrounded_by_rain() -> bool:
	var player_position = get_player().global_position
	var coordinates = precipitation_grid.get_coordinate_at_world_position(player_position)
	return precipitation_grid.is_cell_surrounded(coordinates[0], coordinates[1], 1)
	
func get_grid_tile_size() -> Vector2:
	return Vector2(300, 300)
