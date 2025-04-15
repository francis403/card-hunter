extends CardController
class_name TileEffectCardController


func play_card_action(
	card_resource: CardResource, 
	event_categories: EventCategoryDictionary = null
):
	super.play_card_action(card_resource, event_categories)
	print(play_card_action)
	if not event_categories.has_category("tile_effect"):
		print("ERROR: No power info in card")
	var category_card: TileEffectCategoryCard = event_categories.get_category("tile_effect")
	var target: Piece = get_piece(card_resource, category_card)
	var config: TileHighlightConfig = get_card_tile_highlight_config(category_card)

	var tile_effect_instance: Node = category_card.tile_effect_scene.instantiate()
	if not tile_effect_instance is TileEffect:
		print("tile effect controller is not a tile effect!")
		return
	var tile_effect: TileEffect = tile_effect_instance
	
	BattlemapSignals.awaiting_player_input.emit()
	BattlemapSignals.highlight_tiles.emit(target._tile, config)
	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	
	if tile == null:
		# cancel card
		return
	
	BattlemapSignals.add_effect_to_tile.emit(tile_effect, tile)

	super.after_card_is_played(card_resource, event_categories)
