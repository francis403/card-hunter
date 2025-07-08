extends Resource

## Represents one possible effect a card can have
## TODO: CardEffects within the same card should have a way to transmit info between each other
class_name CardEffect


@export_group("Card Effect Data config")
## This data will configure the effect of all CardEffects in the CardEffect chain.
## It will be commiunicated between all card effects.
## For example, we can check how much data has been done to the monster, 
## or the target of a previous attack and use it instead of asking oto highlight again
var card_effect_data: CardEffectData
## Update the next card effect with the data gathered from the last
@export var update_next_card_effect_data: bool = true

func process_card_effect() -> CardEffectResponse:
	var response = await play_card_effect()
	if not response.should_rollback():
		clean_card_effect()
	return response
	

## Says if the card effect has been played successfully
## Only continues to next effect if so
func play_card_effect() -> CardEffectResponse:
	return CardEffectResponse.new()

## What happens when we cancel the card effect after it has already been played. 
## This is more to do with if you have multiple effects and you cancel it in the middle
## For example, let's say you have a discard effect followed by a move effect
## This revert_card_effect should add the card again
func revert_card_effect() -> bool:
	return false

func update_data_after_card_is_played():
	if not self.card_effect_data:
		self.card_effect_data = CardEffectData.new()
	if not self.card_effect_data.monster_effect_data:
		self.card_effect_data.monster_effect_data = MonsterEffectData.new()

func clean_card_effect() -> void:
	pass
