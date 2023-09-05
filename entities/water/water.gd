class_name Water
extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

var material: ShaderMaterial

func _ready():
	material = mesh.mesh.surface_get_material(0)
	
func get_height_at_position(world_position: Vector3) -> float:
	return 0
