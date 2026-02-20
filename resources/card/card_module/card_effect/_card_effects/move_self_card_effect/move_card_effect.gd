extends CardEffect
## New Type of card module that will take the target from the previous input
class_name MoveCardEffect

@export_group("Tile Highlight Configuration")
@export var tile_highlight_config: TileHighlightConfig

func play_card_effect() -> CardEffectResponse:
	var _response: CardEffectResponse = CardEffectResponse.new()
	_response.set_failure()
	if not _previous_card_module_resp:
		push_error("Previous card_module response necessary but not provided.")
		return _response
	if not _previous_card_module_resp.tile_selected:
		push_error("Previous card_module response has no selected tile")
		return _response
	var _selected_tile: Tile = _previous_card_module_resp.tile_selected
	if not _selected_tile.piece_in_tile:
		push_warning("Previous card_module response tile has no piece in it!")
		return _response
	var _piece_to_move: Piece = _selected_tile.piece_in_tile
	var _tile_to_place_piece: Tile = await _get_user_input(
		tile_highlight_config,
		_piece_to_move
	)
	if not _tile_to_place_piece:
		return _response
	var battlemap: Battlemap = BattleController.battlemap
	battlemap.place_piece_in_tile(_piece_to_move, _tile_to_place_piece)
	if _piece_to_move is PlayerPiece:
		BattlemapSignals.after_player_movement.emit()
	elif _piece_to_move is MonsterPiece:
		_piece_to_move.on_monster_moved_by_player(_tile_to_place_piece)
	_response.set_ok()
	return _response


func _get_user_input(
	_config: TileHighlightConfig,
	_piece_to_move: Piece
) -> Tile:
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
	# show possible squares and await input
	BattlemapSignals.highlight_tiles.emit(
		_piece_to_move._tile,
		_config
	)
	
	var _result = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	return _result
