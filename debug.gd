class_name Debug
extends Object

enum Flag {
	ROPE,
	PLAYER_CONTROLS,
	OCEAN_PLANES,
	WATER_HEIGHT
}

static var flags: Array[Flag] = [
	Flag.ROPE,
	Flag.PLAYER_CONTROLS
]

static func is_flag_enabled(flag: Flag) -> bool:
	return flags.find(flag) != -1
