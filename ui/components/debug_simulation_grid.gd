extends Control

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var grid = World.instance.precipitation_grid
	
	for row in grid.get_row_count():
		for column in grid.get_column_count():
			var tile = grid.get_tile_at_row_column(row, column)
			
			var tile_size = Vector2(30, 30)
			var gutter = 2
			var tile_position = Vector2(
				((tile_size.x + gutter) * column) + tile_size.x,
				((tile_size.y + gutter) * row) + tile_size.y
			)
			
			draw_rect(Rect2(tile_position, tile_size), Color(tile, tile, tile))
			draw_string(
				get_parent().font,
				tile_position + Vector2(5, 10),
				str(round(tile)),
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				10,
				Color.RED
			)
