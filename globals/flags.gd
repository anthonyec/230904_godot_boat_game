class_name Flags
extends Object

const FPS = "FPS"
const ROPE = "ROPE"
const PLAYER_CONTROLS = "PLAYER_CONTROLS"
const OCEAN_PLANES = "OCEAN_PLANES"
const WATER_HEIGHT = "WATER_HEIGHT"
const WATER_RENDER_TIME = "WATER_RENDER_TIME"
const TIME = "TIME"
const OCEAN_SHADER_PARAMS = "OCEAN_SHADER_PARAMS"

static var flags: Array[String] = [
	FPS,
	ROPE,
#	WATER_RENDER_TIME,
#	OCEAN_SHADER_PARAMS,
#	PLAYER_CONTROLS,
#	WATER_HEIGHT,
#	OCEAN_PLANES
]

static func is_enabled(flag: String) -> bool:
	return flags.find(flag) != -1
