## Tracks player progression during the campaign
extends Node

const STARTING_DECK: PlayerDeck =\
	preload("res://resources/player_deck/decks/generic_deck/starting_deck.tres")
	
## Representation of the deck the player currently has equiped
var _deck: PlayerDeck = STARTING_DECK

var _player_class: PlayerClass

var _available_card_modules: Array[CardEffect] = []

## Represents the current player health
var current_player_health: int = -1:
	set(value):
		current_player_health = value
		File.progress.current_health = current_player_health

## Reference to the current world node the player is in.
## TODO: make sure this node is correctly updated
var current_world_node: GenericWorldNode

func _ready() -> void:
	_load_save_data()

func _load_save_data():
	if File.progress.current_player_deck:
		_deck = File.progress.current_player_deck
	
func _load_deck(player_dictionary: Dictionary):
	_deck._load(player_dictionary)

## At some point we are going to initiate deck based on class
func replace_deck(other_deck: PlayerDeck):
	_deck = other_deck.duplicate()
	
func get_deck():
	return _deck
	
func get_card_modules() -> Array[CardEffect]:
	return _available_card_modules

func add_card_module(_card_module: CardEffect):
	_available_card_modules.append(_card_module)

func remove_card_module(_card_module: CardEffect):
	var i: int = 0
	for _card_effect: CardEffect in _available_card_modules:
		if _card_module.equals(_card_effect):
			_available_card_modules.remove_at(i)
			return
		i += 1

func add_card_modules(_card_modules: Array[CardEffect]):
	_available_card_modules.append_array(_card_modules)

func add_card_to_deck(_card_resource: CardResourceV2):
	_deck.add_card(_card_resource)

func remove_card_from_deck(card_id: String):
	_deck.remove_card(card_id)
