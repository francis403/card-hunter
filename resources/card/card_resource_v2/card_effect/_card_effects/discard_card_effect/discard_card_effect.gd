extends CardEffectWithCardSelection

## TODO: what do we do, if the user cancels the effect after the card has been discarded?
## We need to be able to revert it all
## Select 1 enemy and deal damage to it
class_name DiscardCardEffect

var discarded_cards_array: Array[CardResourceV2] = []

func card_effect():
	discarded_cards_array.reverse()
	for card in selected_cards:
		card._discard_card()
		discarded_cards_array.append(card.card_resource)
			
## TODO: revert card being discarded
func revert_card_effect():
	for card_resource in discarded_cards_array:
		BattlemapSignals.card_discarded_from_hand_reverted.emit(card_resource)
	discarded_cards_array.clear()
