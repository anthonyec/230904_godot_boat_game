class_name Deliveries
extends Node

static var active: Array[Delivery] = []

static func add(delivery: Delivery) -> void:
	active.append(delivery)
	pass
	
static func remove(id: String) -> void:
	pass

