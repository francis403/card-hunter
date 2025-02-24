extends CardController
class_name AttackCardController

func play_card_action(
	card_resource: CardResource,
	card_categories: CardCategoryDictionary = null
):
	super.play_card_action(card_resource, card_categories)
	
	if not card_categories.has_category("damage"):
		print("no damage info in card")
	var damage_info_card: DamageCategoryCard = card_categories.get_category("damage")
	
	# The attack is always played by the player
	var piece: Piece = battlemap.player
	#var target = _get_piece(card_resource)
	if not piece:
		print("ERROR: No player found while playig attack card...")
		return
	
	var area_type = get_area_type(card_resource, damage_info_card)
	var range_of_attack = damage_info_card.range
	
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()
	# show possible squares and await input	
	highlight_tiles(piece, area_type, damage_info_card.range)
	
	var tile: Tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	
	if tile.piece_in_tile:
		tile.piece_in_tile.apply_damage(damage_info_card.damage)
