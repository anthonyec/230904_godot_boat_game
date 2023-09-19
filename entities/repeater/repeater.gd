class_name Repeater
extends Node3D

signal tile_created(tile_position: Vector3)
signal tile_removed(tile_position: Vector3)

@export var debug: bool = false
@export var viewer: Node3D
# TODO: Frustum culling is a bit broken because it does not take into account 
# the bounding box of a tile, only the point position.
@export var frustum_cull: bool = false
@export var prevent_below_ground: bool = true
@export var lock_to_ground: bool = false
@export var tile_radius: Vector3i = Vector3i(2, 1, 2)
@export var tile_size: Vector3 = Vector3(100, 100, 100)
@export var tile_offset: Vector3 = Vector3(0, 0, 0)

var camera: Camera3D
var existing_tile_positions: Array[Vector3] = []
var duplicates: Dictionary = {}

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	
	if not viewer and camera:
		viewer = get_viewport().get_camera_3d()
	
	tile_created.connect(_on_tile_created)
	tile_removed.connect(_on_tile_removed)

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
			return false
			
		if frustum_cull and not camera.is_position_in_frustum(tile_position):
			return false
		
		if existing_tile_positions.find(tile_position) == -1:
			existing_tile_positions.append(tile_position)
			tile_created.emit(tile_position)
			
		created_tile_positions.append(tile_position)
		
		if debug:
			if frustum_cull and not viewer.is_position_in_frustum(tile_position):
				DebugDraw.draw_box(tile_position, tile_size, Color.RED)
			else:
				DebugDraw.draw_box(tile_position, tile_size, Color.BLACK)
	)
	
	for index in existing_tile_positions.size():
		var reverse_index = existing_tile_positions.size() - index - 1
		
		# TODO: This is a quick hack to stop reverse index breaking when size is 1.
		if reverse_index < 0:
			continue
			
		var existing_position = existing_tile_positions[reverse_index]
		
		if created_tile_positions.find(existing_position) == -1:
			existing_tile_positions.remove_at(reverse_index)
			tile_removed.emit(existing_position)
			
	if debug:
		DebugDraw.draw_box(nearest_position - tile_offset, tile_size - Vector3(1, 1, 1), Color.WHITE)

func for_each_tiles(callback: Callable) -> void:
	for x in range(-tile_radius.x, tile_radius.x + 1):
		for y in range(-tile_radius.y, tile_radius.y + 1):
			for z in range(-tile_radius.z, tile_radius.z + 1):
				var result = callback.call(x, y, z)
				
				if typeof(result) == TYPE_BOOL and result == false:
					continue
				
func add_duplicate() -> void:
	pass
	
func remove_duplicate() -> void:
	pass

func get_duplicates() -> Array[Node3D]:
	var children: Array[Node3D] = []
	
	for child in get_children():
		children.append(child as Node3D)
		
	return children
	
func start() -> void:
	pass
	
func stop() -> void:
	pass
	
func _on_tile_created(tile_position: Vector3) -> void:
	if get_child_count() == 0:
		return
		
	var child = get_child(0)
	var duplicate_child = child.duplicate() as Node3D
	
	add_child(duplicate_child)
	duplicates[tile_position] = duplicate_child
	duplicate_child.global_position = tile_position
	
func _on_tile_removed(tile_position: Vector3) -> void:
	if not duplicates.has(tile_position):
		return
		
	var duplicate_child = duplicates.get(tile_position) as Node3D
	remove_child(duplicate_child)
