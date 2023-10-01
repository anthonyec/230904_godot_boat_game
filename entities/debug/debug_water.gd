extends Node3D

@export var water: Ocean

func _process(_delta: float) -> void:
	if not Flags.is_enabled(Flags.DEBUG_WATER_HEIGHT):
		return
		
	DebugDraw.draw_cube(global_position + Vector3.DOWN * 10, 0.5, Color.RED)
		
	var size: float = 35

	for y in int(size):
		for x in int(size):
			var pos = Vector3(global_position.x, 0, global_position.z) + Vector3(x, 0, y) - Vector3(size / 2, 0, size / 2)
			var height = World.instance.get_water_height(pos)
			
			var color = Color.BLUE.lerp(Color.CYAN, height)
			DebugDraw.draw_cube(Vector3(pos.x, height, pos.z), 0.2, color)
