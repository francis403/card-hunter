## Tracks player progression during the campaign
extends Node

const STARTING_DECK: PlayerDeck =\
	preload("res://resources/player_deck/decks/generic_deck/starting_deck.tres")
	
## Representation of the deck the player currently has equiped
var _deck: PlayerDeck = STARTING_DECK

## Contains all card modules the player has available
var _available_card_modules: Array[CardModule] = []

## Contains all cards the player has that were forged
var _forged_cards: Dictionary = {}

## Represents the current player health
var current_player_health: int = -1:
	set(value):
		current_player_health = value
		File.progress.current_health = current_player_health

## Reference to the current world node the player is in.
var current_world_node: GenericWorldNode

func _ready() -> void:
	_load_save_data()

func _load_save_data():
	if File.progress.current_player_deck:
		_deck = File.progress.current_player_deck

## At some point we are going to initiate deck based on class
func replace_deck(other_deck: PlayerDeck):
	_deck = other_deck.duplicate()
	
func get_deck():
	return _deck
	
func get_card_modules() -> Array[CardModule]:
	return _available_card_modules

func add_card_module(_card_module: CardModule):
	_available_card_modules.append(_card_module)

func remove_card_module(_card_module: CardModule):
	var i: int = 0
	for _module: CardModule in _available_card_modules:
		if _card_module.equals(_module):
			_available_card_modules.remove_at(i)
			return
		i += 1

func add_card_modules(_card_modules: Array[CardModule]):
	_available_card_modules.append_array(_card_modules)

func add_card_to_deck(_card_resource: CardResourceV2):
	_deck.add_card(_card_resource)

func remove_card_from_deck(card_id: String):
	_deck.remove_card(card_id)
	
func add_forged_card(card_resource: CardResourceV2):
	var id: String = card_resource.id
	if _forged_cards.has(id):
		var quantity: int = _forged_cards[id]["quantity"]
		_forged_cards[id]["quantity"] = (quantity + 1)
		return
	_forged_cards[id] = card_resource.to_dictionary()
	_forged_cards[id]["quantity"] = 1
	
func remove_forged_card(card_resource_id: String):
	if not _forged_cards.has(card_resource_id):
		return
	var quantity: int = _forged_cards[card_resource_id]["quantity"]
	if quantity <= 1:
		_forged_cards.erase(card_resource_id)
	else:
		_forged_cards[card_resource_id]["quantity"] = (quantity - 1)
		
	
