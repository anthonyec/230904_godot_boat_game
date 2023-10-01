extends Control

enum GridType {
	PRECIPITATION,
	WIND,
	WAVE,
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
			draw_vector_grid(World.instance.wind_grid)
		GridType.WAVE:
			draw_vector_grid(World.instance.wave_grid)
			
func get_tile_position(coordinate: Vector2i) -> Vector2:
	return (tile_size + Vector2(gutter, gutter)) * Vector2(coordinate)

func draw_preciptation_grid() -> void:
	var grid = World.instance.precipitation_grid
	var background_size = (Vector2(grid.size.x + gutter, grid.size.y + gutter) * tile_size)
	
	draw_rect(Rect2(Vector2(-gutter, -gutter), background_size), Color.BLACK)
	
	grid.for_each_cell(func(coordinate: Vector2i, value: Vector2):
		var tile_position = get_tile_position(coordinate)
		var tile_center = tile_position + (tile_size / 2)
		var player_coordinate = grid.get_coordinate_at_world_position(player_position)
		
		draw_rect(Rect2(tile_position, tile_size), Color.GRAY)
		draw_rect(Rect2(tile_position, tile_size), Color(0, 0, 1, value.length()))
		
		if player_coordinate == coordinate:
			draw_rect(Rect2(tile_position, tile_size), Color.RED, false, 2)
		
		draw_string(
			get_parent().font,
			tile_position + Vector2(2, 8),
			str(value.length()),
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			9,
			Color.BLACK
		)
	)

func draw_vector_grid(grid: VectorField2D) -> void:
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
