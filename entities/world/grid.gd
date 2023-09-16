class_name Grid
extends Node

var cells: Array[float] = []

var size: Vector2i = Vector2(50, 50)
var world_cell_size: Vector2 = Vector2(300, 300)

func _init(width: int, height: int, value: float = 0) -> void:
	size = Vector2i(width, height)
	resize(width, height)
	fill(value)

static func clone(other_grid: Grid) -> Grid:
	var duplicate_grid = Grid.new(other_grid.size.x, other_grid.size.y)
	var duplicate_cells = other_grid.cells.duplicate(true)
	duplicate_grid.cells = duplicate_cells
	return duplicate_grid
	
func resize(width: int, height: int) -> void:
	cells.resize(width * height)
	
func fill(value: float) -> void:
	cells.fill(value)
	
func for_each_cell(callback: Callable) -> void:
	for index in cells.size():
		var coordinate = get_cell_coordinate(index)
		callback.call(coordinate[0], coordinate[1], cells[index])
		
func get_cell_index(x: int, y: int) -> int:
	var x_w = wrapi(x, 0, size.x)
	var y_w = wrapi(y, 0, size.y)
	return x_w + size.x * y_w
	
func get_cell_coordinate(index: int) -> Array[int]:
	return [index % size.x, index / size.x]
	
func get_coordinate_at_world_position(position: Vector3) -> Array[int]:
	var x = int(round(position.x / world_cell_size.x))
	var y = int(round(-position.z / world_cell_size.y))
	var x_w = wrapi(x, 0, size.x)
	var y_w = wrapi(y, 0, size.y)
	return [x_w, y_w]

func get_cell_at_world_position(position: Vector3) -> float:
	var coordinate = get_coordinate_at_world_position(position)
	return get_cell_at_coordinate(coordinate[0], coordinate[1])

func get_cell_at_coordinate(x: int, y: int) -> float:
	return cells[get_cell_index(x, y)]
	
func set_cell_at_coordinate(x: int, y: int, value: float) -> void:
	cells[get_cell_index(x, y)] = value
	
func get_neihbours_at_coordinate(x: int, y: int) -> Array[float]:
	var values: Array[float] = []
	
	for_neighbours_at_coordinate(x, y, func(x_n, y_n, neighbour_value):
		values.append(neighbour_value)
	)
	
	return values

func for_neighbours_at_coordinate(x: int, y: int, callback: Callable) -> void:
	for x_n in range(-1, 2):
		for y_n in range(-1, 2):
			var neighbour_value = get_cell_at_coordinate(x + x_n, y + y_n)
			callback.call(x_n, y_n, neighbour_value)

func step(callback: Callable, dry_run: bool = false) -> Array[float]:
	var previous_grid = Grid.clone(self)
	var next_grid = Grid.clone(self)
	
	for_each_cell(func(x: int, y: int, _value: float):
		callback.call(previous_grid, next_grid, x, y)
	)
		
	var next_cells = next_grid.cells.duplicate(true)
	
	if not dry_run:
		cells = next_cells
		
	previous_grid.queue_free()
	next_grid.queue_free()
	return next_cells
