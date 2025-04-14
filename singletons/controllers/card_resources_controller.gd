extends Node

## We need a place with all cards, then we need a way to get them all
## TODO: not sure if needed, we can probably just add this to a resource somewhere

const card_resources_folder = "res://resources/card/card_resources"

## TODO: has an object that contains all the cards and if they have been unlocked or not
var _card_in_game: Dictionary = {}

## TODO: read all cards info into the dictionary
func _init() -> void:
	_init_cards_in_game_dictionary()

## TODO: we don't need to go through all the cards twice
## TODO: I'm scared this is going to take a long time
## NOT SURE IF THIS IS A GOOD IDEA (THINK ABOUT THIS)
func _init_cards_in_game_dictionary():
	print(_init_cards_in_game_dictionary)
	var card_resources_paths: Array[String] = get_all_file_paths(card_resources_folder)
	for card_path in card_resources_paths:
		var card_resource: CardResource = load(card_path)
		_card_in_game[card_resource.id] = card_resource
	print("finished")

func get_card(card_id: String) -> CardResource:
	if _card_in_game.has(card_id):
		return _card_in_game[card_id]
	return null
	
func has_card(card_id: String) -> bool:
	return _card_in_game.has(card_id)

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
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
