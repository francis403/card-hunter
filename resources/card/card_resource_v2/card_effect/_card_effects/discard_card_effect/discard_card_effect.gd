extends CardEffectWithCardSelection

## TODO: what do we do, if the user cancels the effect after the card has been discarded?
## We need to be able to revert it all
## Select 1 enemy and deal damage to it
class_name DiscardCardEffect

var card_resource_array: Array[CardResourceV2]

func card_effect():
	for card in selected_cards:
		var is_card_discarded: bool = card._discard_card()
		if is_card_discarded:
			card_resource_array.append(card.card_resource)
			
## TODO: revert card being discarded
func revert_card_effect():
	for card_resource in card_resource_array:
		BattlemapSignals.card_discarded_from_hand_reverted.emit(card_resource)
	card_resource_array.clear()
