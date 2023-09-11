extends Node

func _process(_delta: float) -> void:
	if Debug.is_flag_enabled(Debug.Flag.FPS):
		DebugDraw.set_text("fps", str(Engine.get_frames_per_second()))
