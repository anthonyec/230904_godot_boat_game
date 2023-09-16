extends Control

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var grid = World.instance.precipitation_grid
	
	for row in grid.get_row_count():
		for column in grid.get_column_count():
			var tile = grid.tiles[row][column]
			
			draw_rect(Rect2(20 * row, 20 * column, 20, 20), Color(tile, tile, tile))
			draw_string(
				get_parent().font,
				Vector2(20 * row, 20 * column),
				str(tile),
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				8,
				Color.RED
			)
