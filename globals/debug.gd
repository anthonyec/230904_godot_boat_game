class_name Debug
extends Object

enum Flag {
	FPS,
	ROPE,
	PLAYER_CONTROLS,
	OCEAN_PLANES,
	WATER_HEIGHT,
	WATER_RENDER_TIME,
	TIME,
	OCEAN_SHADER_PARAMS
}

static var flags: Array[Flag] = [
	Flag.FPS,
	Flag.ROPE,
	Flag.WATER_RENDER_TIME,
	Flag.OCEAN_SHADER_PARAMS,
	Flag.PLAYER_CONTROLS,
#	Flag.WATER_HEIGHT,
#	Flag.OCEAN_PLANES
]

static func is_flag_enabled(flag: Flag) -> bool:
	return flags.find(flag) != -1
