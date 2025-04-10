## Tracks player progression during the campaign
extends Node


const STARTING_DECK: PlayerDeck =\
	preload("res://resources/player_deck/decks/generic_deck/starting_deck.tres")
	
	
var _deck: PlayerDeck = STARTING_DECK

var _player_class: PlayerClass

## Reference to the current world node the player is in.
## TODO: make sure this node is correctly updated
var current_world_node: WorldNode

## At some point we are going to initiate deck based on class
func replace_deck(other_deck: PlayerDeck):
	_deck = other_deck.duplicate()
	
func get_deck():
	return _deck
	
