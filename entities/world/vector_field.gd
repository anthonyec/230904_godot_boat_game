class_name VectorField
extends Node

var cells: Array[Vector2] = []

var size: Vector2i = Vector2(50, 50)
var world_cell_size: Vector2 = Vector2(300, 300)

func _init(width: int, height: int, value: Vector2 = Vector2.ZERO) -> void:
	size = GridUtils.init(cells, Vector2i(width, height), value)
	
static func clone(other_grid: VectorField) -> VectorField:
	var duplicate_grid = VectorField.new(other_grid.size.x, other_grid.size.y)
	var duplicate_cells = other_grid.cells.duplicate(true)
	duplicate_grid.cells = duplicate_cells
	
	return duplicate_grid
	
func get_cell_index(coordinate: Vector2i) -> int:
	return GridUtils.get_cell_index(size, coordinate)
	
func get_cell_value_at_coordinate(coordinate: Vector2i) -> Vector2:
	return GridUtils.get_cell_value_at_coordinate(cells, size, coordinate) as Vector2
	
func get_coordinate_at_world_position(world_position: Vector3) -> Vector2i:
	return GridUtils.get_coordinate_at_world_position(world_cell_size, size, world_position)
	
func get_cell_value_at_world_position(world_position: Vector3) -> Vector2:
	return GridUtils.get_cell_value_at_world_position(cells, world_cell_size, size, world_position)

func get_cell_coordinate(index: int) -> Vector2i:
	return GridUtils.get_cell_coordinate(size, index)
	
func set_cell_at_coordinate(coordinate: Vector2i, value: Vector2) -> void:
	return GridUtils.set_cell_at_coordinate(cells, size, coordinate, value)
	
func get_neihbours_at_coordinate(coordinate: Vector2i) -> Array[Vector2]:
	return GridUtils.get_neihbours_at_coordinate(cells, size, coordinate) as Array[Vector2]
	
func for_each_cell(callback: Callable) -> void:
	return GridUtils.for_each_cell(cells, size, callback)

func for_neighbours_at_coordinate(coordinate: Vector2i, callback: Callable) -> void:
	return GridUtils.for_neighbours_at_coordinate(cells, size, coordinate, callback)

func step(callback: Callable, dry_run: bool = false) -> Array[Vector2]:
	var previous_grid = VectorField.clone(self)
	var next_grid = VectorField.clone(self)
	
	for_each_cell(func(coordinate: Vector2i, _value: Vector2):
		callback.call(previous_grid, next_grid, coordinate)
	)
		
	var next_cells = next_grid.cells.duplicate(true)
	
	if not dry_run:
		cells = next_cells
		
	previous_grid.queue_free()
	next_grid.queue_free()
	return next_cells
