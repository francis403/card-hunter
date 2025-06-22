extends Resource
class_name CardEffectResponse

enum CardEffectResponses {
	NONE,
	OK,
	FAILURE_ROLLBACK,
	FAILURE_NO_ROLLBACK
}
	
var response: CardEffectResponses = CardEffectResponses.NONE


func _init(
	_card_effect_responses: CardEffectResponses = CardEffectResponses.NONE
) -> void:
	response = _card_effect_responses

func set_failure(failure_with_rollback: bool = true):
	response = CardEffectResponses.FAILURE_ROLLBACK\
		if failure_with_rollback\
		else CardEffectResponses.FAILURE_NO_ROLLBACK

func set_ok():
	response = CardEffectResponses.OK
	
func is_ok() -> bool:
	return response == CardEffectResponses.OK

func should_rollback() -> bool:
	return response == CardEffectResponses.FAILURE_ROLLBACK
