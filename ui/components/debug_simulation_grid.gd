extends Control

enum GridType {
	PRECIPITATION,
	WIND
}

@export var grid_type: GridType = GridType.PRECIPITATION

func _process(_delta: float) -> void:
	visible = Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS)
		
	if not Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS):
		return
		
	queue_redraw()

func _draw() -> void:
	var player_position = World.instance.get_player().global_position
	var player_grid_coordinate = World.instance.precipitation_grid.get_coordinate_at_world_position(player_position)
	var grid = World.instance.precipitation_grid
	
	if grid_type == GridType.WIND:
		grid = World.instance.wind_grid
	
	var tile_size = Vector2(25, 25)
	var gutter = 0
	
	grid.for_each_cell(func(x: int, y: int, value: float):
		var tile_position = Vector2(
			((tile_size.x + gutter) * x) + tile_size.x,
			((tile_size.y + gutter) * y) + tile_size.y
		)
		var center = tile_position + (tile_size / 2)
		
		draw_rect(Rect2(tile_position, tile_size), Color(value, value, value))
		draw_string(
			get_parent().font,
			tile_position + Vector2(5, 10),
			str(value),
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			10,
			Color.RED
		)
			
		if player_grid_coordinate[0] == x and player_grid_coordinate[1] == y:
			draw_rect(Rect2(tile_position, tile_size), Color.CYAN, false)
	)
				
			
