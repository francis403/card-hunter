## Tracks player progression during the campaign
extends Node

const STARTING_DECK: PlayerDeck =\
	preload("res://resources/player_deck/decks/generic_deck/starting_deck.tres")
	
const TEST_TRAPS_DECK: PlayerDeck =\
	 preload("res://resources/player_deck/decks/test_deck/test_traps_deck.tres")
## Representation of the deck the player currently has equiped
var _deck: PlayerDeck = STARTING_DECK

var _player_class: PlayerClass

## Represents the current player health
var current_player_health: int

## Reference to the current world node the player is in.
## TODO: make sure this node is correctly updated
var current_world_node: WorldNode

func _ready() -> void:
	if File.progress.current_player_deck:
		_deck = File.progress.current_player_deck

func _load_deck(player_dictionary: Dictionary):
	_deck._load(player_dictionary)

## At some point we are going to initiate deck based on class
func replace_deck(other_deck: PlayerDeck):
	_deck = other_deck.duplicate()
	
func get_deck():
	return _deck
	
