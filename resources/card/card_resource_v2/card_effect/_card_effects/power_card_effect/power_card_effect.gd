extends CardEffect

## TODO: add option to aim for other piece
## TODO: we will also need to change the StatusEffect
class_name PowerCardEffect

@export var power_effect: PowerEffect

## TODO: if Monster target type let the player pick a tile first
@export var target_piece: Constants.TargetType

func play_card_effect() -> bool:
	print(play_card_effect, ": TODO")
	if not power_effect:
		return false
	var target: Piece = BattleController.get_player()
	if not target:
		return false
	
	## TODO: What we have to do now is add this to the power_effect_container of the piece
	target.add_power_effect(
		power_effect.init_base_power_node(target)
	)
	
	return true
	
