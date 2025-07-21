extends CardEffect
class_name DeckManipulationCardEffect

@export var deck_manipulation_config: DeckManipulationConfig

func play_card_effect() -> CardEffectResponse:
	var response: CardEffectResponse = CardEffectResponse.new()
	response.set_ok()
	deck_manipulation_config.apply_deck_manipulation()
	return response
