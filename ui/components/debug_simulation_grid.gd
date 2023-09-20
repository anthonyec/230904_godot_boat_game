extends Control

enum GridType {
	PRECIPITATION,
	WIND
}

@export var grid_type: GridType = GridType.PRECIPITATION

var tile_size = Vector2(22, 22)
var gutter = 1

var player_position: Vector3

func _process(_delta: float) -> void:
	visible = Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS)
		
	if not Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS):
		return
	
	player_position = World.instance.get_player().global_position
	
	queue_redraw()

func _draw() -> void:
	match grid_type:
		GridType.PRECIPITATION:
			draw_preciptation_grid()
		GridType.WIND:
			draw_wind_grid()
			
func get_tile_position(coordinate: Vector2i) -> Vector2:
	return (tile_size + Vector2(gutter, gutter)) * Vector2(coordinate)

func draw_preciptation_grid() -> void:
	var grid = World.instance.precipitation_grid
	
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
			
#		if player_grid_coordinate[0] == x and player_grid_coordinate[1] == y:
#			draw_rect(Rect2(tile_position, tile_size), Color.CYAN, false)
	)

func draw_wind_grid() -> void:
	var grid = World.instance.wind_grid
	var background_size = (Vector2(grid.size.x + gutter, grid.size.y + gutter) * tile_size)
	
	draw_rect(Rect2(Vector2(-gutter, -gutter), background_size), Color.BLACK)
	
	grid.for_each_cell(func(coordinate: Vector2i, value: Vector2):
		var tile_position = get_tile_position(coordinate)
		var tile_center = tile_position + (tile_size / 2)
		var arrow_end = tile_center + value * tile_size.x / 2
		var player_coordinate = grid.get_coordinate_at_world_position(player_position)
		
		draw_rect(Rect2(tile_position, tile_size), Color.GRAY)
		Draw.arrow(self, tile_center, arrow_end, 6 * value.length(), 45, Color.BLUE, 1)
		
		if player_coordinate == coordinate:
			draw_rect(Rect2(tile_position, tile_size), Color.RED, false, 2)
	)
