extends CardEffect
class_name DeckManipulationCardEffect

@export var deck_manipulation_config: DeckManipulationConfig

func play_card_effect() -> bool:
	deck_manipulation_config.apply_deck_manipulation()
	return true
