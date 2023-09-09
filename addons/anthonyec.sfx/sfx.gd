extends Node3D

const RANDOM_NUMBER_PLACEHOLDER = "[%n]"

var number_suffix_regex: RegEx = null
var is_loaded: bool = false

# Where all the sounds are stored, with the name as their key and their loaded
# resource as value.
var sounds: Dictionary = {}

func _ready() -> void:
	var sounds_directory = ProjectSettings.get_setting("addons/sfx/sounds")

	if sounds_directory == "" or sounds_directory == null:
		push_warning("No sounds directory has been set in Project Settings. See setup instructions in the README file: res://addons/anthonyec.sfx/README.md")
		return

	number_suffix_regex = RegEx.new()
	number_suffix_regex.compile("\\d+$")

	var sound_files: Array[String] = []

	sound_files.append_array(_get_files_with_extension(sounds_directory, ".wav"))
	sound_files.append_array(_get_files_with_extension(sounds_directory, ".mp3"))
	sound_files.append_array(_get_files_with_extension(sounds_directory, ".ogg"))

	if sound_files.is_empty():
		push_warning("SFX: No sound files were found inside " + sounds_directory)
		return

	sounds = _build_sound_library_from_files(sounds_directory, sound_files)
	is_loaded = true

func create_player_3d(sound_name: String, parameters: Parameters = Parameters.new()) -> AudioStreamPlayer3D:
	if not sounds.has(sound_name.trim_suffix(RANDOM_NUMBER_PLACEHOLDER)):
		push_error("SFX: The sound called '", sound_name, "' does not exist.")
		return AudioStreamPlayer3D.new()

	if sounds.has(sound_name) and sounds[sound_name] is Array:
		push_error("SFX: The sound called '", sound_name, "' is a collection of sounds. Access them by using the '" + RANDOM_NUMBER_PLACEHOLDER + "' suffix.")
		return AudioStreamPlayer3D.new()

	var file = _get_sound_file(sound_name)
	var player: AudioStreamPlayer3D = _spawn_player(file, parameters)

	return player

# Plays a sound at a specfic location in the scene.
func play_at_location(sound_name: String, location: Vector3, parameters: Parameters = Parameters.new()) -> AudioStreamPlayer3D:
	var player = create_player_3d(sound_name, parameters)

	add_child(player)
	player.global_transform.origin = location
	player.play()

	return player

# Plays a sound attached as a child to a node in the scene.
func play_attached_to_node(sound_name: String, node: Node3D, parameters: Parameters = Parameters.new()) -> AudioStreamPlayer3D:
	var player = create_player_3d(sound_name, parameters)

	node.add_child(player)
	player.play()

	return player

# Plays a non-spatial sound in the scene which is not affected by process mode.
# This is good for UI noises as it will still work when the game is paused.
func play_everywhere(sound_name: String, parameters: Parameters = Parameters.new()) -> AudioStreamPlayer2D:
	if !sounds.has(sound_name.trim_suffix(RANDOM_NUMBER_PLACEHOLDER)):
		push_error("SFX: The sound called '", sound_name, "' does not exist.")
		return AudioStreamPlayer2D.new()

	var sound_file = _get_sound_file(sound_name)
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

	var _signal = player.connect("finished", func(): player.queue_free())

	player.set_process_mode(PROCESS_MODE_ALWAYS)
	player.stream = sound_file
	player.bus = parameters.bus
	player.volume_db = parameters.volume_db
	player.pitch_scale = parameters.pitch_scale
	player.max_polyphony = parameters.max_polyphony

	add_child(player)
	player.play()

	return player

func _spawn_player(stream: AudioStream, parameters: Parameters = Parameters.new()) -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	var timer: SceneTreeTimer = get_tree().create_timer(float(stream.get_length()), false)

	player.stream = stream
	player.bus = parameters.bus
	player.attenuation_filter_cutoff_hz = parameters.attenuation_filter_cutoff_hz
	player.volume_db = parameters.volume_db
	player.max_db = parameters.max_db
	player.max_distance = parameters.max_distance
	player.pitch_scale = parameters.pitch_scale

	return player

func _on_timer_end(player: AudioStreamPlayer3D) -> void:
	player.queue_free()

func _get_sound_file(sound_name: String) -> AudioStream:
	var file: AudioStream = null

	if sound_name.ends_with(RANDOM_NUMBER_PLACEHOLDER):
		var sound_collection_name = sound_name.trim_suffix(RANDOM_NUMBER_PLACEHOLDER)
		var number_of_sound_files = sounds[sound_collection_name].size()
		var random_index = floor(randf_range(0, number_of_sound_files))

		file = sounds[sound_collection_name][random_index] as AudioStream
	else:
		file = sounds[sound_name] as AudioStream
	
	return file

func _build_sound_library_from_files(sounds_directory: String, sound_files: Array[String]) -> Dictionary:
	var collection: Dictionary = {}

	for sound_file in sound_files:
		# Turn the full sound file path int oa name, e.g "res://globals/sfx/audio/physics/glass/sound.wav" -> "physics/glass/sound".
		var sound_name = sound_file.replace(sounds_directory, "").trim_prefix("/").replace("." + sound_file.get_extension(), "")
		var number_suffix_match = number_suffix_regex.search(sound_name)

		if number_suffix_match:
			var number = number_suffix_match.get_string()
			var sound_collection_name = sound_name.trim_suffix(number)

			if not collection.has(sound_collection_name):
				collection[sound_collection_name] = []

			collection[sound_collection_name].append(load(sound_file))

		# Add all sounds to the collection, even if they contain a number as
		# this will be faster to lookup (probably). Though it does waste a
		# bit of memory.
		collection[sound_name] = load(sound_file)

	return collection

# Perform a recursive scan of a directory and return all the files of a certain type.
func _get_files_with_extension(path: String, file_extension: String) -> Array[String]:
	var directory = DirAccess.open(path)

	if directory == null:
		push_error("SFX: Failed to open directory: " + path)
		return []

	directory.list_dir_begin()

	var results: Array[String] = []
	var file_name = directory.get_next()

	while file_name != "":
		if directory.current_is_dir():
			var recursive_results = _get_files_with_extension(path + "/" + file_name, file_extension)
			results.append_array(recursive_results)

		if not directory.current_is_dir():
			# When the game is exported, assets no longer exists in their original file form and are instead
			# their binary data is stored in a ".import" file. So we look for those, and then use the original
			# file name by removing the ".import" extension. Godot `load` will work with normal file extensions.
			# https://github.com/godotengine/godot/issues/18390#issuecomment-384041374
			if file_name.ends_with(file_extension + ".import"):
				var file_path_without_import = path + "/" + file_name.replace(".import", "")
				results.append(file_path_without_import)

		file_name = directory.get_next()

	return results

# TODO: Add all the audio params here.
class Parameters extends RefCounted:
	# General params
	var bus: String = "Master"
	var volume_db: float = 0
	var pitch_scale: float = 1

	# 3D only params
	var attenuation_filter_cutoff_hz: int = 20500
	var max_db: float = 0
	var max_distance: float = 30

	# 2D only params
	var max_polyphony: int = 1
