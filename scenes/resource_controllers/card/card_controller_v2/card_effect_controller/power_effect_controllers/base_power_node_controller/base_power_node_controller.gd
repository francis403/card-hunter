extends PowerNodeController

## A Power Node is just a node that stores TriggerEffect Conditions
class_name BasePowerNodeController

var _power_holder_piece: Piece = null
var _number_of_turns_active: int = 0
var _max_number_of_turns_active: int = 0

## I think this makes sence
var target: Piece

## TODO: it's smarter to check the piece itself throwing the signal
func _ready() -> void:
	BattlemapSignals.monster_turn_started.connect(_tick_power_timer)

func add_trigger_effect(base_trigger_effect: BaseTriggerEffectEvent):
	if _power_holder_piece:
		base_trigger_effect.target_piece = _power_holder_piece
	self.add_child(base_trigger_effect)

func _tick_power_timer():
	_number_of_turns_active += 1
	if _number_of_turns_active >= _max_number_of_turns_active:
		self.queue_free()
