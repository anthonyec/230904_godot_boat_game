extends Control

enum GridType {
	PRECIPITATION,
	WIND
}

@export var grid_type: GridType = GridType.PRECIPITATION

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var player_position = World.instance.get_player().global_position
	var player_row_column = World.instance.precipitation_grid.get_row_column_at_position(player_position)
	var grid = World.instance.precipitation_grid
	
	if grid_type == GridType.WIND:
		grid = World.instance.wind_grid
	
	var tile_size = Vector2(25, 25)
	var gutter = 0
	
	for row in grid.get_row_count():
		for column in grid.get_column_count():
			var tile = grid.get_tile_at_row_column(row, column)
	
			var tile_position = Vector2(
				((tile_size.x + gutter) * column) + tile_size.x,
				((tile_size.y + gutter) * row) + tile_size.y
			)
			var center = tile_position + (tile_size / 2)
			
			if typeof(tile) == TYPE_INT or typeof(tile) == TYPE_FLOAT:
				draw_rect(Rect2(tile_position, tile_size), Color(tile, tile, tile))
				draw_string(
					get_parent().font,
					tile_position + Vector2(5, 10),
					str(tile),
					HORIZONTAL_ALIGNMENT_CENTER,
					-1,
					10,
					Color.RED
				)
				
			if typeof(tile) == TYPE_VECTOR2:
				draw_rect(Rect2(tile_position, tile_size), Color(0, 0, 0))
				draw_line(center, center + tile * 5, Color.WHITE)
				
			if player_row_column[0] == row and player_row_column[1] == column:
				draw_rect(Rect2(tile_position, tile_size), Color.CYAN, false)
				
			
