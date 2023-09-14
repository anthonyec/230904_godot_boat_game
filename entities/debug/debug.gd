extends Node

func _process(_delta: float) -> void:
	if Flags.is_enabled(Flags.DEBUG_FPS):
		DebugDraw.set_text("fps", str(Engine.get_frames_per_second()))
