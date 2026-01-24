extends Node

const _PLAY_EFFECT_CARD_MODULES_FILE_PATH = "res://resources/card/card_resource_v2/card_effect/_card_effects/_card_effects_collection/"
const _SPECIAL_EFFECT_CARD_MODULES_FILE_PATH = "res://resources/card/card_resource_v2/special_card_effect/_special_card_effects_collection/"

var _card_modules_in_game: Dictionary = {}

## read all card modules info into the dictionary
func _init() -> void:
	_init_card_modules_in_game_dictionary()

## TODO: we don't need to go through all modules twice
## TODO: I'm scared this is going to take a long time
## NOT SURE IF THIS IS A GOOD IDEA (THINK ABOUT THIS)
func _init_card_modules_in_game_dictionary():
	print(_init_card_modules_in_game_dictionary, ": started loading card_modules...")
	var _time_start = Time.get_ticks_msec()
	var card_modules_resources_paths: Array[String] = []
	var play_effect_card_module_paths: Array[String] = get_all_file_paths(_PLAY_EFFECT_CARD_MODULES_FILE_PATH)
	var special_effect_card_module_paths: Array[String] = get_all_file_paths(_SPECIAL_EFFECT_CARD_MODULES_FILE_PATH)
	var condition_card_module_paths: Array[String] = []
	card_modules_resources_paths.append_array(play_effect_card_module_paths)
	card_modules_resources_paths.append_array(special_effect_card_module_paths)
	card_modules_resources_paths.append_array(condition_card_module_paths)
	for card_module_path in card_modules_resources_paths:
		var card_module: CardModule = load(card_module_path)
		_card_modules_in_game[card_module.id] = card_module
	var _elapsed_time = Time.get_ticks_msec() - _time_start
	print(_init_card_modules_in_game_dictionary, ": finished loading card modules in ", _elapsed_time  ,"ms! Loaded: ", _card_modules_in_game.size(), " modules")

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			# In exported builds, .tres files become .tres.remap
			# Strip .remap suffix so load() can find the actual resource
			if file_path.ends_with(".remap"):
				file_path = file_path.substr(0, file_path.length() - 6)
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths
	
func get_card_module(id: String) -> CardModule:
	if not _card_modules_in_game.has(id):
		return null
	return _card_modules_in_game[id]
