class_name VectorField2D
extends Node

var cells: PackedVector2Array = []

var size: Vector2i
var world_cell_size: Vector2i

func _init(width: int, height: int, world_cell_width: int, world_cell_height: int) -> void:
	size = Vector2i(width, height)
	world_cell_size = Vector2i(world_cell_width, world_cell_height)
	cells.resize(width * height)
	cells.fill(Vector2.ZERO)
	
func clone() -> VectorField2D:
	var new_vector_field = VectorField2D.new(size.x, size.y, world_cell_size.x, world_cell_size.y)
	new_vector_field.cells = cells.duplicate()
	return new_vector_field
	
func get_cell_index(coordinate: Vector2i) -> int:
	var x_w = wrapi(coordinate.x, 0, size.x)
	var y_w = wrapi(coordinate.y, 0, size.y)
	
	return x_w + size.x * y_w
	
func get_cell_value_at_coordinate(coordinate: Vector2i) -> Vector2:
	return cells[get_cell_index(coordinate)]
		
func get_coordinate_at_world_position(world_position: Vector3) -> Vector2i:
	var x = int(round(world_position.x / world_cell_size.x))
	var y = int(round(-world_position.z / world_cell_size.y))
	var x_w = wrapi(x, 0, size.x)
	var y_w = wrapi(y, 0, size.y)
	
	return Vector2i(x_w, y_w)
	
func get_cell_value_at_world_position(world_position: Vector3) -> Vector2:
	var coordinate = get_coordinate_at_world_position(world_position)
	return get_cell_value_at_coordinate(coordinate)

func get_cell_coordinate(index: int) -> Vector2i:
	return Vector2i(index % size.x, index / size.y)
	
func set_cell_at_coordinate(coordinate: Vector2i, value: Vector2) -> void:
	cells[get_cell_index(coordinate)] = value
	
func get_neighbours_at_coordinate(coordinate: Vector2i) -> PackedVector2Array:
	var values: PackedVector2Array = []

	for_neighbours_at_coordinate(coordinate, func(_neighbour_coordinate, neighbour_value):
		values.append(neighbour_value)
	)

	return values
	
func for_each_cell(callback: Callable) -> void:
	for index in cells.size():
		var coordinate = get_cell_coordinate(index)
		callback.call(coordinate, cells[index])

func for_neighbours_at_coordinate(coordinate: Vector2i, callback: Callable) -> void:
	for x_n in range(-1, 2):
		for y_n in range(-1, 2):
			var neighbour_coordinate = Vector2i(coordinate.x + x_n, coordinate.y + y_n)
			var neighbour_value = get_cell_value_at_coordinate(neighbour_coordinate)
			callback.call(neighbour_coordinate, neighbour_value)
			
func is_cell_surrounded(coordinate: Vector2i, condition: Callable) -> bool:
	var values = get_neighbours_at_coordinate(coordinate)
	
	for value in values:
		var result = condition.call(value)
		
		if typeof(result) == TYPE_BOOL and result:
			return true

	return false

func step(callback: Callable) -> void:
	# TODO: Check this doesn't leak memory and create objects.
	var previous_field = clone()
	var next_field = clone()
	
	for_each_cell(func(coordinate: Vector2i, value: Vector2):
		callback.call(previous_field, next_field, coordinate, value)
	)
	
	cells = next_field.cells
	previous_field.queue_free()
	next_field.queue_free()
