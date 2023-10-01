extends Node3D

func _process(delta: float) -> void:
	var player = World.instance.get_player()
	var preciptation = World.instance.get_precipitation(global_position)
	visible = preciptation > 0.12
	
	World.instance.get_wind(global_position)
