extends CardEffect

## TODO: add option to aim for other piece
class_name StatusChangeCardEffect

@export var status_modifier_config: StatusModifierConfig

func play_card_effect():
	var player: PlayerPiece = BattleController.get_player()
	if not player:
		return
	status_modifier_config.apply_status_change(player)
