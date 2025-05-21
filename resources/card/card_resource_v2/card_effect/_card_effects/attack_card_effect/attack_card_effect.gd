extends CardEffectWithUserInput

## Select 1 enemy and deal damage to it
class_name AttackCardEffect

@export var damage: int = 10

func card_effect():
	if not target_tile:
		return
	var player: PlayerPiece = BattleController.get_player()
	if not player:
		return
	if target_tile.piece_in_tile:
		target_tile.piece_in_tile.apply_damage(damage * player._strength)
	elif target_tile.has_effect():
		target_tile.remove_tile_effects()
