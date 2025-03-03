extends CardController
class_name MoveCardController

#TODO: if the player cancels the pick I need to stop awaiting

func play_card_action(
	card_resource: CardResource, 
	card_categories: EventCategoryDictionary = null
):
	super.play_card_action(card_resource, card_categories)

	if not card_can_be_played(card_resource, card_categories):
		return
	
	if not card_categories.has_category("move"):
		print("ERROR: no move info in card")
	var move_card_category: MoveCategoryCard = card_categories.get_category("move")
	
	var piece_to_move: Piece = get_piece(card_resource, move_card_category)
	var area_type: Constants.AreaType = get_area_type(card_resource, move_card_category)
		
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
		
	# show possible squares and await input	
	BattlemapSignals.highlight_move_tiles.emit(
		piece_to_move._tile,
		move_card_category.move_distance,
		area_type
	)
	#highlight_tiles(piece_to_move, area_type, move_card_category.move_distance)
	
	# await signal
	var tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	
	if tile == null:
		# cancel card
		return
	
	battlemap.place_piece_in_tile(piece_to_move, tile)
	after_card_is_played(card_resource, card_categories)
