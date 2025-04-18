extends StatusEffect

## TODO: complete this
class_name GenericStatusEffectController

var effect_extra_cost_config: EffectExtraCostConfig = null
var status_modifier_config: StatusModifierConfig = null
var status_trigger: Constants.EffectTrigger = Constants.EffectTrigger.ON_SELF_PLAYED

var _number_of_turns: int
var _max_number_of_turns: int = 1

func _init() -> void:
	_number_of_turns = 0
	
func _ready() -> void:
	super._ready()
	if not self.status_effect_config:
		return
	self.effect_extra_cost_config = self.status_effect_config.extra_cost
	self.status_modifier_config = self.status_effect_config.status_modifier_config
	self.status_trigger = self.status_effect_config.effect_trigger
	_max_number_of_turns = self.status_effect_config.number_of_turns
	_subscripe_on_status_trigger()
	
func _subscripe_on_status_trigger():
	match status_trigger:
		Constants.EffectTrigger.ON_SELF_PLAYED:
			on_effect_triggered()
		Constants.EffectTrigger.ON_END_OF_PLAYER_TURN:
			BattlemapSignals._on_monster_turn_started.connect(on_effect_triggered)
	
func on_effect_gain():
	_on_status_effect_gain_cost()

## I want this to be the function that is called when the status effect is triggered
## The sub status effects will simply need to change the apply_effect()
func on_effect_triggered():
	print(on_effect_triggered)
	_on_status_effect_trigger_cost()
	status_effect_trigger()
	_on_status_effect_finished_cost()
	_on_end_of_effect_trigger()


func _apply_on_play_cost():
	if not effect_extra_cost_config.extra_cost_timing ==\
		EffectExtraCostConfig.ExtraCostTiming.ON_SELF_PLAYED:
		return
	## TODO: apply cost

func _on_status_effect_gain_cost():
	pass

func _on_status_effect_trigger_cost():
	pass

func status_effect_trigger():
	if status_modifier_config:
		_apply_status_modifier()

func _apply_status_modifier():
	print(_apply_status_modifier)
	match status_modifier_config.stat:
		Constants.StatType.STRENGTH:
			var target_strenght: int = target._strength
			target._strength = clamp(
				status_modifier_config.get_changed_value(target_strenght),
				0,
				100
			)
		Constants.StatType.HEALTH:
			target._health = clamp(
				status_modifier_config.get_changed_value(target._health),
				0,
				100
			)
			BattlemapSignals.player_health_changed.emit(target._health)
	pass

func _on_status_effect_finished_cost():
	pass

func _on_status_effect_discarded_cost():
	pass

func _on_end_of_effect_trigger():
	_number_of_turns += 1
	if _number_of_turns >= _max_number_of_turns:
		self.on_effect_discarded()

func on_effect_discarded():
	self.target.remove_status(self.id)
	self.queue_free()
