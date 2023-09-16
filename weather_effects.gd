class_name WeatherEffects
extends Node3D

var grid_size: int = 8

func _process(delta: float) -> void:
	var world = World.instance
	var tile_size = world.get_grid_tile_size()
	var viewer_position = world.get_player().global_position
	
	var nearest_tile_position = Vector3(
		(round(viewer_position.x / tile_size.x) * tile_size.x),
		0,
		(round(viewer_position.z / tile_size.y) * tile_size.y)
	)
	
	for x in grid_size:
		for z in grid_size:
			if x == grid_size / 2 and z == grid_size / 2:
				continue
			
			var duplicate_position = Vector3(
				(nearest_tile_position.x + tile_size.x * x) - (tile_size.x / 2 * grid_size),
				0,
				(nearest_tile_position.z + tile_size.y * z) - (tile_size.y / 2 * grid_size)
			)
			
			if Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS):
				if viewer_position.distance_to(duplicate_position) > 900:
#					DebugDraw.draw_box(duplicate_position, Vector3(1, 50, 1), Color.BLACK)
#					DebugDraw.draw_box(duplicate_position, Vector3(tile_size.x, 0.1, tile_size.y), Color.BLACK)
					
					if world.get_precipitation(duplicate_position) > 0.5:
						DebugDraw.draw_box(duplicate_position, Vector3(tile_size.x, 10, tile_size.y), Color.BLUE)
	
	if Flags.is_enabled(Flags.DEBUG_SIMULATION_GRIDS):
		DebugDraw.draw_box(nearest_tile_position, Vector3(1, 50, 1), Color.RED)
		DebugDraw.draw_box(nearest_tile_position, Vector3(tile_size.x, 0.1, tile_size.y), Color.RED)

