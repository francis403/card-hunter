extends SpecialCardEffectResource
class_name CardEventTriggerSpecialEffectResource

enum CardEventTriggerEnum {
	CARD_PLAYED,
	CARD_DISCARDED
}

@export var card_event_trigger: CardEventTriggerEnum

## By default, on card_event_trigger do PowerEffect
@export var card_effects: Array[CardEffect]

func get_trigger_label() -> String:
	match card_event_trigger:
		CardEventTriggerEnum.CARD_PLAYED:
			return "On Play"
		CardEventTriggerEnum.CARD_DISCARDED:
			return "On Discard"
	return ""

## Subscribes the CardEventTriggerSpecialEffectController
func subscribe_to_trigger(card: Card):
	match card_event_trigger:
		CardEventTriggerEnum.CARD_PLAYED:
			if not card.card_played.is_connected(trigger_card_effects):
				card.card_played.connect(trigger_card_effects)
		CardEventTriggerEnum.CARD_DISCARDED:
			if not card.card_discarded_by_effect.is_connected(trigger_card_effects):
				card.card_discarded_by_effect.connect(trigger_card_effects)

func trigger_card_effects():
	for card_effect: CardEffect in card_effects:
		GeneralUtils.debug_log(
			"-- Processing card effect %s." % [card_effect.id]
		)
		await card_effect.process_card_effect()
		GeneralUtils.debug_log(
			"-- Card effect %s finished!" % [card_effect.id]
		)
