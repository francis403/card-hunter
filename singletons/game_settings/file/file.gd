extends Node

const SAVE_FILE_PATH = "user://card_hunter.save"
var save_data: Dictionary = {
	"settings": {},
	"progress": {}
}

var settings: Settings
var progress: Progress

func _ready() -> void:
	BattlemapSignals.player_world_state_updated.connect(_on_player_world_state_updated_signal)
	settings = Settings.new()
	progress = Progress.new()

func delete_save():
	DirAccess.remove_absolute(SAVE_FILE_PATH)

func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	
func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()
	load_settings()
	load_progress()
	

func change_settings():
	save_data["settings"]["volume"] = settings.volume
	save()

func change_progress():
	save_data["progress"]["player_world_node_id"] = progress.current_world_node_id
	save_data["progress"]["world_state"] = progress.world_state.to_dictionary()
	save_data["progress"]["world_state"]["days_left"] = GameController.days_till_attack
	save_data["progress"]["world_state"]["villages_saved"] = GameController.number_of_villages_saved
	save_data["progress"]["player"] = PlayerController.get_deck().save()
	save_data["progress"]["player"]["hp"] = PlayerController.current_player_health
	save_data["progress"]["player"]["card_modules"] = convert_player_card_modules_to_dictionary()
	save_data["progress"]["player"]["forged_cards"] = PlayerController._forged_cards
	save_data["progress"]["player"]["player_node_id"] = progress.current_world_node_id
	save()

func convert_player_card_modules_to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	var index: int = 0
	for module: CardModule in PlayerController.get_card_modules():
		result[index] = module.to_dictionary()
		index += 1
	return result

func load_settings():
	if save_data["settings"].has("volume"):
		self.settings.volume = save_data["settings"]["volume"]
		
func load_progress():
	if save_data["progress"].has("player_world_node_id"):
		self.progress.current_world_node_id = save_data["progress"]["player_world_node_id"]
	if save_data["progress"].has("world_state"):
		_load_world_state()
	if save_data["progress"].has("player"):
		_load_player_info()
	
func update_player_position(_world_node: GenericWorldNode):
	self.progress.update_player_position(_world_node)
	
func _load_world_state():
	if save_data["progress"]["world_state"].has("villages_saved"):
		GameController.number_of_villages_saved = save_data["progress"]["world_state"]["villages_saved"]
	if save_data["progress"]["world_state"].has("days_left"):
		GameController.days_till_attack = save_data["progress"]["world_state"]["days_left"]
	self.progress.load_world(save_data["progress"]["world_state"])

## TODO: this can probably be done a lot better
func _load_player_info():
	var player_deck_info: Dictionary = save_data["progress"]["player"]
	progress.current_health = save_data["progress"]["player"]["hp"]
	PlayerController.current_player_health = progress.current_health
	if player_deck_info.has("card_modules"):
		_load_player_card_modules(
			player_deck_info["card_modules"]
		)
	if player_deck_info.has("forged_cards"):
		_load_player_forged_cards(
			player_deck_info["forged_cards"]
		)
	progress.current_player_deck._load(player_deck_info)
	
## TODO: ideally we could just add/remove the cards that are different
func _load_player_card_modules(_player_card_modules_dict: Dictionary):
	PlayerController._available_card_modules.clear()
	for key: int in _player_card_modules_dict.keys():
		var card_module: CardModule = CardEffect.new()
		if _player_card_modules_dict[key].has("scene_path"):
			card_module = ResourceLoader.load(_player_card_modules_dict[key]["scene_path"]).new()
		card_module.from_dictionary(_player_card_modules_dict[key])
		PlayerController.add_card_module(card_module)

func _load_player_forged_cards(_dict: Dictionary):
	PlayerController._forged_cards.clear()
	for key: String in _dict.keys():
		var card_resource: CardResourceV2 = CardResourceV2.new()
		card_resource.from_dictionary(_dict[key])
		PlayerController.add_forged_card(card_resource)

## SIGNALS

func _on_player_world_state_updated_signal(_world_node: GenericWorldNode):
	## TODO: currently just updating one node, will need to find a way to update all nodes that are changed
	progress.world_state.update_node_in_world_state(_world_node)
	change_progress()
