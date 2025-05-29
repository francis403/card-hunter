extends CardEffectWithCardSelection

## Select 1 enemy and deal damage to it
class_name DiscardCardEffect

## TODO: pick a card
func card_effect():
	for card in selected_cards:
		if card is Card:
			card._discard_card()
