extends CardController
class_name PushCardController

func play_card_action(
	card_resource: CardResource, 
	card_categories: EventCategoryDictionary = null
):
	super.play_card_action(card_resource, card_categories)
	
	if not card_can_be_played(card_resource, card_categories):
		return
		
	if not card_categories.has_category("move"):
		print("no move info in card")
	var move_card_category: MoveCategoryCard = card_categories.get_category("move")
	
	var piece_to_move: Piece = get_piece(card_resource, move_card_category)
	var area_type = get_area_type(card_resource, move_card_category)
	var player = battlemap.player
	
	# show possible squares and await input	
	highlight_tiles(player, area_type, move_card_category.range)

	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()

	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
	
	if not tile.piece_in_tile:
		BattlemapSignals.canceled_player_input.emit()
		return
	
	BattlemapSignals.clear_highlighted_tiles.emit()
	
	highlight_tiles(piece_to_move, area_type, move_card_category.move_distance)

	tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	battlemap.place_piece_in_tile(piece_to_move, tile)
	
	after_card_is_played(card_resource, card_categories)
