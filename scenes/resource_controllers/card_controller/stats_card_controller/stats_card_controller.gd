extends CardController

func play_card_action(
	card_resource: CardResource, 
	card_categories: CardCategoryDictionary = null
):
	super.play_card_action(card_resource, card_categories)
	
	if not card_can_be_played(card_resource, card_categories):
		return
	
	if not card_categories.has_category("stat_change"):
		print("No stat_change info in card")
	var stats_card_category: StatsCategoryCard = card_categories.get_category("stat_change")
	
	var target: Piece = get_piece(card_resource, stats_card_category)
	
	target._stamina += stats_card_category.change_value
	if target is PlayerPiece:
		BattlemapSignals.player_stamina_changed.emit(target._stamina)
