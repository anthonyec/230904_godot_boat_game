class_name Grid
extends Node

var tiles: Array[Array] = [[]]

var origin: Vector3 = Vector3.ZERO
var tile_size: Vector2 = Vector2(300, 300)

func _init(tiles: Array[Array]) -> void:
	self.tiles = tiles
	
func get_row_count() -> int:
	return tiles.size()
	
func get_column_count() -> int:
	return tiles[0].size()

func get_row_column_at_position(position: Vector3) -> Array[int]:
	var row = int(round(origin.x + position.x / tile_size.x))
	var column = int(round(origin.z + position.z / tile_size.y))
	
	return [
		wrapi(row, 0, get_row_count()),
		wrapi(column, 0, get_column_count())
	]

func get_tile_at_position(position: Vector3) -> float:
	var row_column = get_row_column_at_position(position)
	return tiles[row_column[0]][row_column[1]]
	
func get_tile_at_row_column(row: int, column: int) -> float:
	return tiles[wrapi(row, 0, get_row_count())][wrapi(column, 0, get_column_count())]
	
func set_tile_at_row_column(row: int, column: int, value: float) -> void:
	tiles[wrapi(row, 0, get_row_count())][wrapi(column, 0, get_column_count())] = value
	
func for_neighbours_at_row_column(row: int, column: int, callback: Callable) -> void:
	for neighbour_row in range(-1, 2):
		for neighbour_column in range(-1, 2):
			if neighbour_row == 0 and neighbour_column == 0:
				continue
				
			var neighbour = get_tile_at_row_column(row + neighbour_row, column + neighbour_column)
			callback.call(neighbour_row, neighbour_column, neighbour)

func simulate_step(callback: Callable) -> void:
	var previous_grid = Grid.new(tiles.duplicate(true))
	var next_grid = Grid.new(tiles.duplicate(true))
	
	for row in get_row_count():
		for column in get_column_count():
			callback.call(previous_grid, next_grid, row, column)

	self.tiles = next_grid.tiles.duplicate(true)
