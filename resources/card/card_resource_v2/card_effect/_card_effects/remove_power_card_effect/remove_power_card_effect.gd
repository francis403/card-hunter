extends CardEffect
class_name RemovePowerCardEffect

@export var remove_all_negative_effects: bool = false
@export var remove_all_positive_effects: bool = false
@export var remove_specific_status_effects: Array[String] = []

## TODO: do way of targeting monster
func play_card_effect() -> bool:
	var target: Piece = BattleController.get_player()
	if not target:
		return false
	if self.remove_all_negative_effects:
		target.remove_all_power_effects()
	elif not remove_specific_status_effects.is_empty():
		for status_effect_id in remove_specific_status_effects:
			target.remove_power_effect(status_effect_id)
	return true
