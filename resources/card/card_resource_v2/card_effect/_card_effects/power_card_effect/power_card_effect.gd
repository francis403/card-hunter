extends CardEffect

## TODO: add option to aim for other piece
## TODO: we will also need to change the StatusEffect
class_name PowerCardEffect

@export var power_effect: PowerEffect

func play_card_effect() -> bool:
	print(play_card_effect, ": TODO")
	if not power_effect:
		return false
	var target: Piece = BattleController.get_player()
	if not target:
		return false
	## TODO: generate instance of the power controller
	#var status_effect_instance: StatusEffect = null
	
	## add it to the target
	#if status_effect_instance:
		#target.add_status(status_effect_instance)
	return true
	
