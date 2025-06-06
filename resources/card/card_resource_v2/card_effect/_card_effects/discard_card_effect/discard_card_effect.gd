extends CardEffectWithCardSelection

## TODO: what do we do, if the user cancels the effect after the card has been discarded?
## We need to be able to revert it all
## Select 1 enemy and deal damage to it
class_name DiscardCardEffect

var discarded_cards_array: Array[CardResourceV2] = []

func card_effect():
	discarded_cards_array.clear()
	for card in selected_cards:
		discarded_cards_array.append(card.card_resource)
		BattlemapSignals.card_discarded_by_other_card.emit(card)
		card.card_discarded_by_effect.emit()
		card._discard_card()
			
## TODO: revert card being discarded
func revert_card_effect():
	for card_resource in discarded_cards_array:
		BattlemapSignals.card_discarded_from_hand_reverted.emit(card_resource)
	discarded_cards_array.clear()
