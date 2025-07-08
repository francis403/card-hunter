extends BaseSpecialEffect
class_name CardEventTriggerSpecialEffectController

var card_event_trigger_special_effect_resource: CardEventTriggerSpecialEffectResource

func _init_special_effect(
	_card: Card,
	special_card_effect_resource: SpecialCardEffectResource
):
	self.card = card
	self.card_event_trigger_special_effect_resource = special_card_effect_resource 

func _ready() -> void:
	if not card_event_trigger_special_effect_resource:
		return
	card_event_trigger_special_effect_resource.subscribe_to_trigger(card)
