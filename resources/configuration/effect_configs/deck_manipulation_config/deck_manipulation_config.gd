extends Resource
class_name DeckManipulationConfig

enum DeckEffectEnum {
	DRAW_N_RANDOM_CARDS,
	DRAW_N_SPECIFIC_CARDS
}

@export_group("Deck Manipulation effect")
@export var deck_effect: DeckEffectEnum
@export var n: int = 1
@export var specific_card_id: Array[String]

@export var deck: Constants.DeckType

func apply_deck_manipulation():
	match deck_effect:
		DeckEffectEnum.DRAW_N_RANDOM_CARDS:
			BattlemapSignals.draw_pile_draw_cards_requested.emit(n)
		DeckEffectEnum.DRAW_N_SPECIFIC_CARDS:
			pass
