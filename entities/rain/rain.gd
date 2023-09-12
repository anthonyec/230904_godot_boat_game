extends Node3D

@export var world: World

func _process(_delta: float) -> void:
	var player = world.get_player()
#	global_position = player.global_position
