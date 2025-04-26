extends StatusEffect
class_name DoubleSpeedStatusEffect

@export var number_of_turns: int = 2

var _turn_count: int = 0

func on_effect_gain():
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started)
	if self.status_effect_config:	
		number_of_turns = status_effect_config.number_of_turns
	apply_effect()
	
func _on_monster_turn_started():
	_turn_count += 1
	if _turn_count >= number_of_turns:
		self.on_effect_discarded()
	
func apply_effect():
	self.target._speed *= 2
	
func on_effect_discarded():
	self.target._speed = target.base_speed
	self.target.remove_status(self.id)
	self.queue_free()
	#super.on_effect_discarded()
