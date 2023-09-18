@tool
extends EditorPlugin

var command_palette = get_editor_interface().get_command_palette()

func _enter_tree() -> void:
	var command_callable = Callable(self, "external_command")
	
	# TODO: Can do tutorial or update docs about this. Because I thought it 
	# was EditorInterface.get_resource_filesystem. That's what these docs suggest: 
	# https://docs.godotengine.org/en/stable/classes/class_editorfilesystem.html#description
	var editor_file_system = get_editor_interface().get_resource_filesystem()
	editor_file_system.connect("filesystem_changed", _on_filesystem_change)
	
	load_scripts()

func _exit_tree() -> void:
	unload_scripts()

func execute_script(file_name: String) -> void:
	var file = FileAccess.open("res://scripts/" + file_name, FileAccess.READ)
	
	if not file:
		return
	
	var code = file.get_as_text()
	
	var script = GDScript.new()
	script.source_code = code
	script.reload()
	
	var object = script.new()
	
	if typeof(object) != TYPE_OBJECT:
		return
	
	object = object as Object
	
	if not object.has_method("_run"):
		return
	
	object._run()

func _on_filesystem_change() -> void:
	unload_scripts()
	load_scripts()

var added_scripts: Array[String] = []

func unload_scripts() -> void:
	for script in added_scripts:
		command_palette.remove_command("scripts/" + script.to_snake_case())
		
	added_scripts = []

func load_scripts() -> void:
	var directory = DirAccess.open("res://scripts")
	
	if not directory:
		return
	
	directory.list_dir_begin()
	
	var scripts: Array[String] = []
	var file_name = directory.get_next()
	
	while file_name != "":
		if not directory.current_is_dir() and file_name.ends_with(".gd"):
			scripts.append(file_name)
		
		file_name = directory.get_next()
		
	for script in scripts:
		command_palette.add_command(
			script,
			"scripts/" + script.to_snake_case(),
			execute_script.bind(script)
		)
		
		added_scripts.append(script)

