class_name Water
extends Node3D

@export var depth_viewport: SubViewport

@onready var mesh: MeshInstance3D = $MeshInstance3D

var material: ShaderMaterial

func _ready():
	material = mesh.mesh.surface_get_material(0)
	
func _process(_delta: float) -> void:
	var texture = depth_viewport.get_texture()
	
	print(texture.get_image().get_size())
	var pixel = texture.get_image().get_pixel(1, 1)
	print(pixel)
	
func get_height_at_position(world_position: Vector3) -> float:
	return 0
