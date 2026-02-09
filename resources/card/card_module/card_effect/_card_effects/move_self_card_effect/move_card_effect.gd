extends CardEffectWithUserInput
## New Type of card module that will take the target from the previous input
class_name MoveCardEffect

## TODO: how do I say this required a input of type x?

func _modify_tile_highlight_config() -> TileHighlightConfig:
	## TODO: We are doing this too much, we should have a common space where the effects can get and set data
	var player: Piece = BattleController.get_player()
	if not player: 
		return tile_highlight_config
	var new_config: TileHighlightConfig = tile_highlight_config.duplicate()
	new_config._range = tile_highlight_config._range * player._speed
	return new_config

func card_effect():
	if target_tile == null:
		return
	var player: Piece = BattleController.get_player()
	if not player: 
		return
	var battlemap: Battlemap = BattleController.battlemap
	battlemap.place_piece_in_tile(player, target_tile)
	after_effect_is_played()
	BattlemapSignals.after_player_movement.emit()

func after_effect_is_played():
	pass
