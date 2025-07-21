extends SpecialCardEffectResource
class_name CardEventTriggerSpecialEffectResource

enum CardEventTriggerEnum {
	CARD_PLAYED,
	CARD_DISCARDED
}



@export var card_event_trigger: CardEventTriggerEnum

## By default, on card_event_trigger do PowerEffect
@export var card_effects: Array[CardEffect]

## Subscribes the CardEventTriggerSpecialEffectController 
func subscribe_to_trigger(card: Card):
	match card_event_trigger:
		CardEventTriggerEnum.CARD_PLAYED:
			card.card_played.connect(trigger_card_effects)
		CardEventTriggerEnum.CARD_DISCARDED:
			card.card_discarded_by_effect.connect(trigger_card_effects)

func trigger_card_effects():
	for card_effect in card_effects:
		await card_effect.process_card_effect()
