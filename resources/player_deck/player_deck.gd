extends Resource

## Representation of a deck held by a player
class_name PlayerDeck

@export var _deck: Array[CardResource] = []

## TODO: need to build this for performance sake
var _deck_dictionary: Dictionary = {}

func add_card(card: CardResource):
	_deck.append(card)

## TODO: this does not look nice, use the dictionary once done
func remove_card(card: CardResource):
	for i in range(_deck.size()):
		if _deck[i] == card:
			_deck.remove_at(i)

func get_size() -> int:
	return _deck.size()

func save() -> Dictionary:
	var save_date: Dictionary = {
		"deck": {}
	}
	var i: int = 0
	for card in _deck:
		save_date["deck"][i] = card.id
		i += 1
	return save_date
	
func _load(deck_dictionary: Dictionary):
	if not deck_dictionary.has("deck"):
		print("Deck dictionary does not have deck property")
		return
	_deck.clear()
	for card_key in deck_dictionary["deck"].keys():
		var card_id: String = deck_dictionary["deck"][card_key]
		var card_resource: CardResource = CardResourcesController.get_card(card_id)
		_deck.append(card_resource)
