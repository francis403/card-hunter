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
		print("ERROR: no move info in card")
		
	var move_card_category: MoveCategoryCard = card_categories.get_category("move")
	var config: TileHighlightConfig = get_card_tile_highlight_config(move_card_category)
	var target_type: Constants.TargetType\
		= get_target_type(card_resource, move_card_category)
	var area_type = get_area_type(card_resource, config.area_type)
	var player: PlayerPiece = battlemap.player
	
	# show possible squares and await input
	config.area_type = area_type
	config.range = config.range
	highlight_tiles(player, config)

	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()

	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
		
	if not tile or not tile.piece_in_tile:
		BattlemapSignals.canceled_player_input.emit()
		return
	var piece_to_move: Piece = tile.piece_in_tile
	
	BattlemapSignals.clear_player_highlighted_tiles.emit()
	config.range = move_card_category.move_distance
	highlight_tiles(piece_to_move, config)

	tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	battlemap.place_piece_in_tile(piece_to_move, tile)

	if piece_to_move is MonsterPiece:
		piece_to_move.on_monster_moved_by_player(tile)
		
	after_card_is_played(card_resource, card_categories)

func _build_highlight_config(
	area_type: Constants.AreaType,
	move_info_card: MoveCategoryCard
) -> TileHighlightConfig:
	var config = TileHighlightConfig.new()
	config.area_type = area_type
	config.range = move_info_card.move_distance
	return config
