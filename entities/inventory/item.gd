class_name InventoryItemResource
extends Resource

enum Model {
	DEBUG
}

@export var name: String = "Item"
@export var model: Model
@export var size: Vector2i = Vector2i(1, 1)
@export var weight: float = 1
