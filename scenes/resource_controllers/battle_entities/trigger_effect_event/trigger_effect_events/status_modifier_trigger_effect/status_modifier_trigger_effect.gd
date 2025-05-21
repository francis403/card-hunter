extends BaseTriggerEffectEvent

## Modifies a Status every time it is triggered
class_name StatusModifierTriggerEffectEvent

var trigger_effect_event: StatusModifierTriggerEffectEventResource

func _do_effect():
	if target_piece and trigger_effect_event and trigger_effect_event.status_modifier_config:
		trigger_effect_event.status_modifier_config.apply_status_change(target_piece)
