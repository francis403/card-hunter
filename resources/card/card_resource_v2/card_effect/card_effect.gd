extends Resource

## Represents one possible effect a card can have
## TODO: CardEffects within the same card should have a way to transmit info between each other
class_name CardEffect

## Says if the card effect has been played successfully
## Only continues to next effect if so
func play_card_effect() -> bool:
	return false
