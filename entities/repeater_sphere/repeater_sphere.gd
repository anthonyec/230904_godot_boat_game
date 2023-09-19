# TODO: Rename to RepeaterRing or something because that what it do!
class_name RepeaterSphere
extends Node3D

@export var debug: bool = false
@export var viewer: Node3D
@export var frustum_cull: bool = false
@export var radius: float = 600
@export var tile_size: Vector3 = Vector3(300, 300, 300)
@export var tile_count: int = 8

var camera: Camera3D
var existing_tile_positions: Array[Vector3] = []
var duplicates: Dictionary = {}

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	
	if not viewer and camera:
		viewer = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	for index in tile_count:
		var angle = (float(index) / float(tile_count)) * (PI * 2) 
		var x = sin(angle)
		var z = cos(angle)
		var direction = Vector3(x, 0, z).normalized()
		
		var tile_position = viewer.global_position + (direction * radius)
		DebugDraw.draw_box(tile_position, tile_size, Color.BLACK)
		pass
