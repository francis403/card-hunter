extends CardController
class_name AttackCardController

func play_card_action(card_resource: CardResource):
	if not battlemap:
		battlemap = BattleController.battlemap
	
	# The attack is always played by the player right? 
	var piece: Piece = battlemap.player
	var target = _get_piece(card_resource)
	if not piece:
		print("ERROR: No player found while playig attack card...")
		return
	
	var range_of_attack = card_resource.max_distance
	
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
		# show possible squares and await input	
	highlight_tiles(piece, card_resource)
	
	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	
	if tile.piece_in_tile:
		tile.piece_in_tile.apply_damage(card_resource.damage_done)
