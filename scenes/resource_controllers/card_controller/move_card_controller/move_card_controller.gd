extends CardController
class_name MoveCardController


func play_card_action(card_resource: CardResource):
	if not battlemap:
		battlemap = BattleController.battlemap
	
	var piece_to_move: Piece = _get_piece(card_resource)
		
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
		
	# show possible squares and await input	
	highlight_tiles(piece_to_move, card_resource)
	
	# await signal
	var tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	battlemap.place_piece_in_tile(piece_to_move, tile)
