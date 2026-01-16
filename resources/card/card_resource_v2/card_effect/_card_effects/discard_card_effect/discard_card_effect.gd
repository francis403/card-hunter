extends CardEffectWithCardSelection

class_name DiscardCardEffect

var discarded_cards_array: Array[CardResourceV2] = []

func card_effect():
	discarded_cards_array.clear()
	for card in selected_cards:
		discarded_cards_array.append(card.card_resource)
		await BattleController.discard_card_from_player(card)
		card.card_discarded_by_effect.emit()
			
func revert_card_effect():
	for card_resource in discarded_cards_array:
		BattlemapSignals.card_discarded_from_hand_reverted.emit(card_resource)
	discarded_cards_array.clear()
