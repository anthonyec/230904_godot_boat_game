@tool
extends Control

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var time = "08:45" if Engine.is_editor_hint() else World.instance.get_display_time()

	draw_string(
		get_parent().font,
		size/2,
		time,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		42,
		Color.WHITE,
	)
