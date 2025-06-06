extends BaseTriggerEffectEvent

## Modifies a Status every time it is triggered
class_name StatusModifierTriggerEffectEvent

var status_modifier_config: StatusModifierConfig

func _do_effect():
	if target_piece and status_modifier_config:
		status_modifier_config.apply_status_change(target_piece)
		
func _exit_tree() -> void:
	print(_exit_tree)
	if target_piece and status_modifier_config:
		status_modifier_config.apply_revert_status_change(target_piece)
