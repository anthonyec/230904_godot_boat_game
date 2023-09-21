extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(delta: float) -> void:
	var wind = World.instance.get_wind(global_position)	
	var target_speed_scale: float = 0 if wind.length() < 0.3 else wind.length() * 2
	
	animation_player.speed_scale = lerp(animation_player.speed_scale, target_speed_scale, delta * 5)
