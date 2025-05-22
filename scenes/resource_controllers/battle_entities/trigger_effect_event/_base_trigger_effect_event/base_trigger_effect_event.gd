extends Node
class_name BaseTriggerEffectEvent

var id: String = ""
var trigger: TriggerEffectEventResource.EventTriggerEffectEnum
var target_piece: Piece = null

func _ready() -> void:
	if not target_piece:
		print(BaseTriggerEffectEvent, " ERROR: Missing configuration for trigger Effect Event")
		return
	self._subscribe_to_trigger()
	self._on_effect_gained()


func _subscribe_to_trigger():
	match trigger:
		TriggerEffectEventResource.EventTriggerEffectEnum.ON_INSTANTIATED:
			_do_effect()
		TriggerEffectEventResource.EventTriggerEffectEnum.ON_END_OF_PLAYER_TURN:
			BattlemapSignals.monster_turn_started.connect(_do_effect)

## Override only _do_effect(), the trigger event is automatically triggered
func _do_effect():
	pass

## Occurres at the end of _ready()
func _on_effect_gained():
	pass
	
func _discard_trigger_effect():
	self.queue_free()
