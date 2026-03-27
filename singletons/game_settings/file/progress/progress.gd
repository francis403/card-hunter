extends Resource
class_name Progress

var current_health: int
var current_world_node_id: String:
	set(value):
		if current_world_node_id and current_world_node_id != value:
			var _old_node: GenericWorldNode = world_state.get_world_node(current_world_node_id)
			if _old_node:
				_old_node.hide_player()
		current_world_node_id = value
		GameController.current_player_node_id = current_world_node_id

## Already loaded world
var village_node: VillageWorldNode

## Dictionary representation of the world
var world_state: WorldState

## Representation of the deck the player currently has equiped
var current_player_deck: PlayerDeck


## Default values
func _init() -> void:
	current_health = -1
	current_world_node_id = Constants.VILLAGE_NODE_ID
	current_player_deck = PlayerDeck.new()
	world_state = WorldState.new()
	
func load_progress(_dict: Dictionary):
	_propagate_default_progress_values()
	if _dict.has("player_world_node_id"):
		current_world_node_id = _dict["player_world_node_id"]
	if _dict.has("world_state"):
		load_world(_dict["world_state"])
	if _dict.has("player"):
		_load_player_info(_dict["player"])

func _propagate_default_progress_values():
	GameController.number_of_villages_saved = 0
	GameController.days_till_attack = GameController.DEFAULT_DAYS_TILL_ATTACK
	## TODO: add default health
	PlayerController.current_player_health = 100

func load_world(_dict: Dictionary):
	if _dict.has("villages_saved"):
		GameController.number_of_villages_saved = _dict["villages_saved"]
	if _dict.has("days_left"):
		GameController.days_till_attack = _dict["days_left"]
	world_state.load_world_state(_dict)
	var _loaded_village_node: GenericWorldNode = world_state.load_node_from_memory(Constants.VILLAGE_NODE_ID)
	self.village_node = _loaded_village_node

func _load_player_info(_dict: Dictionary):
	var _loaded_hp: int = 100
	if _dict.has("hp"):
		self.current_health = _dict["hp"]
	PlayerController.current_player_health = self.current_health
	if _dict.has("card_modules"):
		_load_player_card_modules(
			_dict["card_modules"]
		)
	if _dict.has("forged_cards"):
		_load_player_forged_cards(
			_dict["forged_cards"]
		)
	self.current_player_deck._load(_dict)

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
		var saved_quantity: int = _dict[key].get("quantity", 1)
		PlayerController._forged_cards[card_resource.id]["quantity"] = saved_quantity

func update_player_position(current_world_node: GenericWorldNode):
	if not PlayerController.current_world_node:
		PlayerController.current_world_node = current_world_node
	PlayerController.current_world_node.hide_player()
	File.progress.current_world_node_id = current_world_node.world_node_id
	PlayerController.current_world_node = current_world_node
	PlayerController.current_world_node.show_player()
