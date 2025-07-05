extends Node

## TODO: figure out a way to distribute monsters semi-equally
## TODO: need to add some basic logic for monster-weights
##   Probably going to have to change the way we are generatic the monsters that are available

const _GENERIC_MONSTER_DICTIONARY_FIELD = "generic_monsters"
const _BOSS_MONSTER_DICTIONARY_FIELD = "boss_monsters"

const _generic_monsters_folder_path: String = "res://scenes/monsters/generic_monsters"
const _boss_monsters_folder_path: String = "res://scenes/monsters/boss_monsters"

var _generic_monsters_list: Array[GenericMonster] = []
var _boss_monsters_list: Array[GenericMonster] = []

var _monsters_in_game_dictionary: Dictionary = {
	_GENERIC_MONSTER_DICTIONARY_FIELD: {},
	_BOSS_MONSTER_DICTIONARY_FIELD: {}
}

## read all cards info into the dictionary
func _init() -> void:
	_init_monsters_in_game_dictionary()

func _init_monsters_in_game_dictionary():
	_init_generic_monsters_in_game()
	#_init_boss_monsters_in_game()
	
func _init_generic_monsters_in_game():
	print(_init_generic_monsters_in_game, ": loading monsters...")
	var _generic_monster_dictionary: Dictionary = _monsters_in_game_dictionary[_GENERIC_MONSTER_DICTIONARY_FIELD]
	var generic_monsters_file_path_list: Array[String] = get_all_scene_file_paths(_generic_monsters_folder_path)
	
	for generic_monster_path in generic_monsters_file_path_list:
		var monster: GenericMonster = load(generic_monster_path).instantiate()
		if not _generic_monster_dictionary.has(monster.monster_id):
			_generic_monster_dictionary[monster.monster_id] = monster
			_generic_monsters_list.append(monster)
	print(_init_generic_monsters_in_game, ": finished loading monsters! Loaded ", _generic_monsters_list.size(), " monsters")

func _init_boss_monsters_in_game():
	var monster_dictionary: Dictionary = _monsters_in_game_dictionary[_BOSS_MONSTER_DICTIONARY_FIELD]
	var boss_monsters_file_path_list: Array[String] = get_all_scene_file_paths(_boss_monsters_folder_path)
	
	for monster_path in boss_monsters_file_path_list:
		var monster: GenericMonster = load(monster_path).instantiate()
		if not monster_dictionary.has(monster.monster_id):
			monster_dictionary[monster.monster_id] = monster
			_boss_monsters_list.append(monster)

func get_specific_monster(monster_id: String) -> GenericMonster:
	if not _monsters_in_game_dictionary[_GENERIC_MONSTER_DICTIONARY_FIELD].has(monster_id):
		return null
	return _monsters_in_game_dictionary[_GENERIC_MONSTER_DICTIONARY_FIELD][monster_id]

func get_random_generic_monster() -> GenericMonster:
	var random_monster: GenericMonster = _generic_monsters_list.pick_random()
	return random_monster.duplicate()
	
func get_all_scene_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_scene_file_paths(file_path)  
		else:
			if file_path.ends_with(".tscn"):
				file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
