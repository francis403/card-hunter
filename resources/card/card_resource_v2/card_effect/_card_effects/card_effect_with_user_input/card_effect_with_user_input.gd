extends CardEffect
class_name CardEffectWithUserInput

@export_group("Tile Highlight Configuration")
@export var tile_highlight_config: TileHighlightConfig
@export var center_piece: Constants.TargetType

var target_tile: Tile = null

func play_card_effect() -> bool:
	var tile_config: TileHighlightConfig = _modify_tile_highlight_config()
	before_user_input()
	await _get_user_input(tile_config)
	if not target_tile:
		return false
	card_effect()
	_after_card_effect()
	return true

func _get_user_input(config: TileHighlightConfig, piece: Piece = null) -> Tile:
	var piece_to_move: Piece = get_piece() if not piece else piece
	#config.range = piece_to_move._speed * move_card_category.move_distance
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()

	# show possible squares and await input
	BattlemapSignals.highlight_tiles.emit(
		piece_to_move._tile,
		config
	)
	
	target_tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	return target_tile
	

## Override to define the behaviour before the user is asked for input
func before_user_input():
	pass

## Override to define a new TileHighlightConfiguration. 
## Happens before before_user_input()
func _modify_tile_highlight_config() -> TileHighlightConfig:
	return tile_highlight_config
	

## Override to define the card_effect after the user input
func card_effect():
	pass

## Override to define what happens after the card effect is played
func _after_card_effect():
	pass

func get_piece() -> Piece:
	match center_piece:
		Constants.TargetType.MONSTER:
			return BattleController.get_monster()
	return BattleController.get_player()
