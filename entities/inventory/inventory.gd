class_name Inventory
extends Node

@export var items: Array[InventoryItemResource] = []
@export var positions: Array[Vector2i] = []
@export var size: Vector2i = Vector2i(10, 5)
@export var previous_inventory: Inventory = null
@export var next_inventory: Inventory = null

func _ready() -> void:
	assert(items.size() == positions.size(), "Item and position arrays should be in sync but their sizes were different")

func can_item_fit(item: InventoryItemResource, position: Vector2i) -> bool:
	var bounds = position + item.size
	return bounds.x <= size.x and bounds.y <= size.y

func add_item(item: InventoryItemResource, position: Vector2i) -> void:
	items.append(item)
	positions.append(position)
	assert(items.size() == positions.size(), "Item and position arrays should be in sync but their sizes were different")
	
func remove_item(position: Vector2i) -> void:
	var position_index = positions.find(position)
	
	if position_index == -1:
		push_warning("Can't find inventory item at: ", position)
		return
		
	var item_index = positions.find(position)
	assert(item_index == position_index, "Item and position index should be in sync but their indices were different")
		
	items.remove_at(position_index)
	positions.remove_at(position_index)

func link_before(new_inventory: Inventory) -> void:
	if previous_inventory:
		previous_inventory.next_inventory = new_inventory
		
	new_inventory.previous_inventory = previous_inventory
	new_inventory.next_inventory = self
	
	previous_inventory = new_inventory
	
func link_after(new_inventory: Inventory) -> void:
	if next_inventory:
		next_inventory.previous_inventory = new_inventory
		
	new_inventory.previous_inventory = self
	new_inventory.next_inventory = next_inventory
	
	next_inventory = new_inventory

func _exit_tree() -> void:
	if previous_inventory and next_inventory:
		previous_inventory.next_inventory = next_inventory
		next_inventory.previous_inventory = previous_inventory
		
	if previous_inventory and not next_inventory:
		previous_inventory.next_inventory = null
		
	if not previous_inventory and next_inventory:
		next_inventory.previous_inventory = null
