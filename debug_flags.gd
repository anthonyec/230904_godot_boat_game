class_name DebugFlags
extends Object

static var flags: Array[String] = ["rope"]

static func is_enabled(flag: String) -> bool:
	return flags.find(flag) != -1
