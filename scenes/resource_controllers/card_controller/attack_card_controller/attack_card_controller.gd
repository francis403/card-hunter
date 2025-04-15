extends CardController
class_name AttackCardController

func play_card_action(
	card_resource: CardResource,
	card_categories: EventCategoryDictionary = null
):
	super.play_card_action(card_resource, card_categories)
	
	if not card_can_be_played(card_resource, card_categories):
		return
	
	if not card_categories.has_category("damage"):
		print("ERROR: no damage info in card")
	var damage_info_card: DamageCategoryCard = card_categories.get_category("damage")
	var config: TileHighlightConfig = get_card_tile_highlight_config(damage_info_card)
	
	var piece: Piece = BattleController.get_player()
	if not piece:
		print("ERROR: No player found while playig attack card...")
		return
	
	var area_type = get_area_type(card_resource, config.area_type)
	config.area_type = area_type
	
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
	
	# show possible squares and await input	
	highlight_tiles(piece, config)
	
	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	
	if not tile:
		return
		
	if tile.piece_in_tile:
		tile.piece_in_tile.apply_damage(damage_info_card.damage)
		
	after_card_is_played(card_resource, card_categories)
