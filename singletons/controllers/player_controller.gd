## Tracks player progression during the campaign
extends Node

const STARTING_DECK: PlayerDeck =\
	preload("res://resources/player_deck/decks/generic_deck/starting_deck.tres")
	
	
## TODO: we need to initialize the deck based on a couple of things.
##	it would be nice to be able to override the deck based on testing scenarios
## when a battle starts, we set the draw deck equal to this deck
var _deck: PlayerDeck = STARTING_DECK

## TODO: need to figure out how to represent this
var _player_class: String

## At some point we are going to initiate deck based on class
func replace_deck(other_deck: PlayerDeck):
	_deck = other_deck.duplicate()
	
func get_deck():
	return _deck
