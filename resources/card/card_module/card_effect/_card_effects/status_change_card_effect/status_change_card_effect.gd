extends CardEffect

## TODO: add option to aim for other piece
class_name StatusChangeCardEffect

@export var status_modifier_config: StatusModifierConfig

func play_card_effect() -> CardEffectResponse:
	var response: CardEffectResponse = CardEffectResponse.new()
	var player: PlayerPiece = BattleController.get_player()
	if not player:
		response.set_failure()
		return response
	status_modifier_config.apply_status_change(player)
	response.set_ok()
	return response
