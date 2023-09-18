class_name Repeater
extends Node3D

signal tile_created(tile_position: Vector3)
signal tile_removed

@export var debug: bool = false
@export var viewer: Node3D
@export var prevent_below_ground: bool = true
@export var lock_to_ground: bool = false
@export var tile_radius: Vector3i = Vector3i(2, 1, 2)
@export var tile_size: Vector3 = Vector3(100, 100, 100)
@export var tile_offset: Vector3 = Vector3(0, 0, 0)

var existing_tile_positions: Array[Vector3] = []

func _ready() -> void:
	if viewer:
		return
		
	var camera = get_viewport().get_camera_3d()
		
	if not camera:
		push_error("No viewer or camera to use as viewer in repeater")
		return
		
	viewer = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	var nearest_position = (viewer.global_position / tile_size).round() * tile_size
	
	if lock_to_ground:
		nearest_position.y = 0
		
	if prevent_below_ground and viewer.global_position.y < 0:
		nearest_position.y = 0

	var created_tile_positions: Array[Vector3] = []
	
	for_each_tiles(func(x: int, y: int, z: int):
		var tile_position = nearest_position + Vector3(x * tile_size.x, y * tile_size.y, z * tile_size.z)
		tile_position -= tile_offset
		
		if prevent_below_ground and y < 0:
			return
		
		if existing_tile_positions.find(tile_position) == -1:
			existing_tile_positions.append(tile_position)
			tile_created.emit(tile_position)
			
		created_tile_positions.append(tile_position)
		DebugDraw.draw_box(tile_position, tile_size, Color.BLACK)
	)
	
	for index in existing_tile_positions.size():
		var reverse_index = existing_tile_positions.size() - index - 1
		var existing_position = existing_tile_positions[reverse_index]
		
		if created_tile_positions.find(existing_position) == -1:
			existing_tile_positions.remove_at(reverse_index)
			tile_removed.emit()
			
	if debug:
		DebugDraw.draw_box(nearest_position - tile_offset, tile_size - Vector3(1, 1, 1), Color.WHITE)

func for_each_tiles(callback: Callable) -> void:
	for x in range(-tile_radius.x, tile_radius.x + 1):
		for y in range(-tile_radius.y, tile_radius.y + 1):
			for z in range(-tile_radius.z, tile_radius.z + 1):
				callback.call(x, y, z)
