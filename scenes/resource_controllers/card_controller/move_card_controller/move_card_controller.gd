extends CardController
class_name MoveCardController

func play_card_action(card_resource: CardResource):
	if not battlemap:
		battlemap = BattleController.battlemap
	var piece = _get_piece(card_resource)
	
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
		
	# show possible squares and await input	
	_highlight_tiles(piece, card_resource)
	
	# await signal
	var tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	battlemap.place_piece_in_tile(piece, tile)

func _highlight_tiles(piece: Piece, card_resource: CardResource):
	if card_resource.area_type == CardResource.AREA_TYPE.RADIUS:
		battlemap.highligh_tiles_radius(
			piece,
			card_resource.max_distance
		)
	elif card_resource.area_type == CardResource.AREA_TYPE.CROSS:
		battlemap.highligh_tiles_cross(
			piece,
			card_resource.max_distance
		)
	elif card_resource.area_type == CardResource.AREA_TYPE.SPECIFIC:
		print("TODO: specific movement")
