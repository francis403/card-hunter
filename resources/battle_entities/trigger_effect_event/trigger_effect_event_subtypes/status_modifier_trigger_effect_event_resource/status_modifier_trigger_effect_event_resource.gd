extends TriggerEffectEventResource
class_name StatusModifierTriggerEffectEventResource

@export var status_modifier_config: StatusModifierConfig

func _init_trigger_effect(target: Piece) -> BaseTriggerEffectEvent:
	var result: BaseTriggerEffectEvent = super._init_trigger_effect(target)
	if result is StatusModifierTriggerEffectEvent:
		result.status_modifier_config = status_modifier_config.duplicate()
	return result
