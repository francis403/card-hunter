extends Resource
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
