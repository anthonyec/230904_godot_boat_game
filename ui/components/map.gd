@tool
class_name Map
extends Control

@export var center: Vector2
@export var ratio: float = 0.5

enum MarkerType {
	PIN
}

enum MarkerColor {
	DEFAULT
}

func _ready() -> void:
	add_marker(Vector3(-28, 0, -90), "Wind turbines")

func _process(_delta: float) -> void:
	center = size / 2
	queue_redraw()
	
func _draw() -> void:
	draw_line(Vector2(center.x - 10, center.y), Vector2(center.x + 10, center.y), Color.BLUE, 1)
	draw_line(Vector2(center.x, center.y - 10), Vector2(center.x, center.y + 10), Color.BLUE, 1)
	draw_rect(Rect2(0, 0, size.x, size.y), Color.BLUE, false, 2)

func add_marker(world_position: Vector3, label: String = "", type: MarkerType = MarkerType.PIN, color: MarkerColor = MarkerColor.DEFAULT) -> void:
	pass
