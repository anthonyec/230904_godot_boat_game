class_name GridUtils
extends Object

static func init(cells: Array, grid_size: Vector2i, value: Variant = null) -> Vector2i:
	cells.resize(grid_size.x * grid_size.y)
	cells.fill(value)
	return grid_size
		
static func get_cell_index(grid_size: Vector2i, coordinate: Vector2i) -> int:
	var x_w = wrapi(coordinate.x, 0, grid_size.x)
	var y_w = wrapi(coordinate.y, 0, grid_size.y)
	
	return x_w + grid_size.x * y_w
	
static func get_cell_value_at_coordinate(cells: Array, grid_size: Vector2i, coordinate: Vector2i) -> Variant:
	return cells[get_cell_index(grid_size, coordinate)]
		
static func get_coordinate_at_world_position(world_cell_size: Vector2i, grid_size: Vector2i, world_position: Vector3) -> Vector2i:
	var x = int(round(world_position.x / world_cell_size.x))
	var y = int(round(-world_position.z / world_cell_size.y))
	var x_w = wrapi(x, 0, grid_size.x)
	var y_w = wrapi(y, 0, grid_size.y)
	
	return Vector2i(x_w, y_w)
	
static func get_cell_value_at_world_position(cells: Array, world_cell_size: Vector2i, grid_size: Vector2i, world_position: Vector3) -> Variant:
	var coordinate = get_coordinate_at_world_position(world_cell_size, grid_size, world_position)
	return get_cell_value_at_coordinate(cells, grid_size, coordinate)

static func get_cell_coordinate(grid_size: Vector2i, index: int) -> Vector2i:
	return Vector2i(index % grid_size.x, index / grid_size.y)
	
static func set_cell_at_coordinate(cells: Array, grid_size: Vector2i, coordinate: Vector2i, value: Variant) -> void:
	cells[get_cell_index(grid_size, coordinate)] = value
	
static func get_neihbours_at_coordinate(cells: Array, grid_size: Vector2i, coordinate: Vector2i) -> Array:
	var values: Array = []

	for_neighbours_at_coordinate(cells, grid_size, coordinate, func(_neihbour_coordinate, neighbour_value):
		values.append(neighbour_value)
	)

	return values
	
static func for_each_cell(cells: Array, grid_size: Vector2i, callback: Callable) -> void:
	for index in cells.size():
		var coordinate = get_cell_coordinate(grid_size, index)
		callback.call(coordinate, cells[index])

static func for_neighbours_at_coordinate(cells: Array, grid_size: Vector2i, coordinate: Vector2i, callback: Callable) -> void:
	for x_n in range(-1, 2):
		for y_n in range(-1, 2):
			var neihbour_coordinate = Vector2i(coordinate.x + x_n, coordinate.y + y_n)
			var neighbour_value = get_cell_value_at_coordinate(cells, grid_size, neihbour_coordinate)
			callback.call(x_n, y_n, neighbour_value)
			
static func is_cell_surrounded(cells: Array, grid_size: Vector2i, coordinate: Vector2i, condition: Callable) -> bool:
	var values = get_neihbours_at_coordinate(cells, grid_size, coordinate)
	
	for value in values:
		var result = condition.call(value)
		
		if typeof(result) == TYPE_BOOL and result:
			return true

	return false

static func step(cells: Array, grid_size: Vector2i, callback: Callable) -> Array:
	var previous_cells = cells.duplicate(true)
	var next_cells = cells.duplicate(true)
	
	for_each_cell(cells, grid_size, func(coordinate: Vector2i, _value: Variant):
		callback.call(previous_cells, next_cells, coordinate)
	)
		
	return next_cells
