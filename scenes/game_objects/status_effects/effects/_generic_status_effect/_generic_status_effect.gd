extends StatusEffect
class_name GenericStatusEffectController

var effect_extra_cost_config: EffectExtraCostConfig = null
var status_modifier_config: StatusModifierConfig = null

func _init() -> void:
	if not self.status_effect_config:
		return
	self.effect_extra_cost_config = self.status_effect_config.extra_cost
	self.status_modifier_config = self.status_effect_config.status_modifier_config
	## TODO: if we care about the time a card is played, connect to the signal
	
func on_effect_gain():
	_on_status_effect_gain_cost()

## I want this to be the function that is called when the status effect is triggered
## The sub status effects will simply need to change the apply_effect()
func on_effect_triggered():
	_on_status_effect_trigger_cost()
	apply_effect()
	_on_status_effect_finished_cost()


func _apply_on_play_cost():
	if not effect_extra_cost_config.extra_cost_timing ==\
		EffectExtraCostConfig.ExtraCostTiming.ON_SELF_PLAYED:
		return
	## TODO: apply cost

func _on_status_effect_gain_cost():
	pass

func _on_status_effect_trigger_cost():
	pass

func _on_status_effect_finished_cost():
	pass

func _on_status_effect_discarded_cost():
	pass
