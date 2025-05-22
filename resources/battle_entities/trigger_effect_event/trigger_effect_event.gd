extends Resource

## A TriggerEffectEvent represents something that will happen on a specific effect.
class_name TriggerEffectEventResource

enum EventTriggerEffectEnum {
	ON_INSTANTIATED,
	ON_EVERY_CARD_PLAYED,
	ON_MOVE_CARD_PLAY,
	ON_STATUS_APPLIED,
	ON_START_OF_PLAYER_TURN,
	ON_END_OF_PLAYER_TURN
}

@export var id: String
@export var effect_trigger: EventTriggerEffectEnum

@export var effect_controller: PackedScene

func _init_trigger_effect(target: Piece) -> BaseTriggerEffectEvent:
	var result = effect_controller.instantiate()
	result.id = self.id
	result.trigger = self.effect_trigger
	result.target_piece = target
	return result
