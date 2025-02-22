extends CardController
class_name PushCardController

func play_card_action(card_resource: CardResource):
	if not battlemap:
		battlemap = BattleController.battlemap
	
	var piece_to_move: Piece = _get_piece(card_resource)
	var player = battlemap.player
	
	# show possible squares and await input	
	highlight_tiles(player, card_resource)

	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()

	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
	
	#pick the square to move the monster to now
	
	if not tile.piece_in_tile:
		BattlemapSignals.canceled_player_input.emit()
		return
	
	BattlemapSignals.clear_highlighted_tiles.emit()
	
	# show possible squares and await input	
	highlight_tiles(piece_to_move, card_resource)

	tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	battlemap.place_piece_in_tile(piece_to_move, tile)
