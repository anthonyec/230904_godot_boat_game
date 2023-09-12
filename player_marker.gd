@tool
extends Control

@export var map: Map
@export var player: Node3D

func _process(_delta: float) -> void:
	var forward = -player.global_transform.basis.z
	var heading = Vector2(forward.x, forward.z).normalized()
	
	if not Engine.is_editor_hint():
		rotation = heading.angle() - deg_to_rad(-90)
		position = map.center + Vector2(
			player.global_position.x, 
			player.global_position.z
		) * map.ratio
		
	pivot_offset = size / 2
	
	queue_redraw()

func _draw() -> void:
	draw_polygon([
		Vector2(size.x / 2, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y),
		Vector2(size.x / 2, 0)
	], [Color.BLUE])
	pass
