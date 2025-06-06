extends Resource

## Represents one possible effect a card can have
## TODO: CardEffects within the same card should have a way to transmit info between each other
class_name CardEffect

## Says if the card effect has been played successfully
## Only continues to next effect if so
func play_card_effect() -> bool:
	return false

## What happens when we cancel the card effect after it has already been played. 
## This is more to do with if you have multiple effects and you cancel it in the middle
## For example, let's say you have a discard effect followed by a move effect
## This revert_card_effect should add the card again
func revert_card_effect() -> bool:
	return false
