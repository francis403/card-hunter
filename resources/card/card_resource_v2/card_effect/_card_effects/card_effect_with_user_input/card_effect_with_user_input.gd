extends CardEffect
class_name CardEffectWithUserInput

@export_group("Tile Highlight Configuration")
@export var tile_highlight_config: TileHighlightConfig
@export var center_piece: Constants.TargetType

var target_tile: Tile = null

func play_card_effect() -> CardEffectResponse:
	var response: CardEffectResponse = CardEffectResponse.new()
	var tile_config: TileHighlightConfig = _modify_tile_highlight_config()
	before_user_input()
	await _get_user_input(tile_config)
	if not target_tile:
		response.set_failure()
		return response
	card_effect()
	_after_card_effect()
	response.set_ok()
	return response

func _get_user_input(config: TileHighlightConfig, piece: Piece = null) -> Tile:
	
	## check if we want to use a previous selected tile
	target_tile = get_previous_select_tile()
	if target_tile:
		return target_tile
	
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

## null if none or we don't want to use it
func get_previous_select_tile() -> Tile:
	if card_effect_data:
		return card_effect_data.get_previous_selected_tile_if_enabled()
	return null

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
	update_data_after_card_is_played()

func update_data_after_card_is_played():
	super.update_data_after_card_is_played()
	if target_tile:
		self.card_effect_data.last_selected_tile = Vector2(
			target_tile._x_position,
			target_tile._y_position
		)
	

func get_piece() -> Piece:
	match center_piece:
		Constants.TargetType.MONSTER:
			return BattleController.get_monster()
	return BattleController.get_player()
