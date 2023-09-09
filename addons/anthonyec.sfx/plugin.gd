@tool
extends EditorPlugin

const AUTOLOAD_NAME = "SFX"
const AUTOLOAD_SCRIPT_PATH = "res://addons/anthonyec.sfx/sfx.gd"
const SETTINGS_PATH = "addons/sfx/sounds"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)

func _enable_plugin() -> void:
	ProjectSettings.set_setting(SETTINGS_PATH, "")
	ProjectSettings.set_initial_value(SETTINGS_PATH, "")
	
	ProjectSettings.add_property_info({
		"name": SETTINGS_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR,
		"hint_string": ""
	})
	
	ProjectSettings.save()
	
func _disable_plugin() -> void:
	if ProjectSettings.get_setting(SETTINGS_PATH, null):
		ProjectSettings.clear(SETTINGS_PATH)
