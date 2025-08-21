extends CardEffectWithCardSelection

class_name DiscardCardEffect

var discarded_cards_array: Array[CardResourceV2] = []

##TODO: the await here fixes the issue which happens if more than one card is discarded at once, but it's not ideal
func card_effect():
	discarded_cards_array.clear()
	for card in selected_cards:
		discarded_cards_array.append(card.card_resource)
		BattlemapSignals.card_discarded_by_other_card.emit(card)
		card.card_discarded_by_effect.emit()
		await card._discard_card()
			
func revert_card_effect():
	for card_resource in discarded_cards_array:
		BattlemapSignals.card_discarded_from_hand_reverted.emit(card_resource)
	discarded_cards_array.clear()
