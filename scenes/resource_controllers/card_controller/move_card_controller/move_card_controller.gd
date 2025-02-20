extends CardController
class_name MoveCardController

#var piece: Piece = null

#func _ready() -> void:
	#BattlemapSignals.tile_picked_in_battlemap.connect(_on_tile_picked_signal)
	
# TODO:
#	1. Show possible Tiles to click in
#	2. Hear the click
#	3. Once clicked move the Piece there
func play_card_action(card_resource: CardResource):
	if not battlemap:
		battlemap = BattleController.battlemap
	var piece = _get_piece(card_resource)
	
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
		
	# show possible squares and await input	
	battlemap.highligh_tiles_around_piece(
		piece,
		card_resource.max_distance
	)
	
	# await signal
	var tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	battlemap.place_piece_in_tile(piece, tile)

func _get_piece(card_resource: CardResource):
	if card_resource.affects == card_resource.AFFECTS_ENUM.SELF:
		return battlemap.player
	return battlemap.monster


#func _on_tile_picked_signal(tile: Tile):
	#print(_on_tile_picked_signal)
	#if piece:
		#BattlemapSignals.player_input_received.emit()
		#battlemap.place_piece_in_tile(piece, tile)
