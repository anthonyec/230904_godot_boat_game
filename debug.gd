extends Node

func _process(delta: float) -> void:
	DebugDraw.set_text("fps: " + str(Engine.get_frames_per_second()))
