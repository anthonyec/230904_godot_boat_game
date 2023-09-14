class_name Utils
extends Node

static func get_children_by_class(parent: Node, className: Variant) -> Array[Node]:
	var children: Array[Node] = []
	
	for child in parent.get_children(false):
		if child.is_instance_of(className):
			children.append(child)
		
	return children
