extends CardController
class_name StatsCardController

func play_card_action(
	card_resource: CardResource, 
	event_categories: EventCategoryDictionary = null
):
	super.play_card_action(card_resource, event_categories)
	
	if not card_can_be_played(card_resource, event_categories):
		return
	
	if not event_categories.has_category("stat_change"):
		print("ERROR: No stat_change info in card")
	var stats_card_category: StatsCategoryCard = event_categories.get_category("stat_change")
	
	var target: Piece = get_piece(card_resource, stats_card_category)
	
	if stats_card_category.stat_type == Constants.StatType.STAMINA:
		target._stamina += stats_card_category.change_value
		if target is PlayerPiece:
			target._stamina = min(target._max_stamina, target._stamina)
			BattlemapSignals.player_stamina_changed.emit(target._stamina)
	elif stats_card_category.stat_type == Constants.StatType.HEALTH:
		target._health += stats_card_category.change_value
		if target is PlayerPiece:
			target._health = min(target._max_hp, target._health)
			BattlemapSignals.player_health_changed.emit(target._health)
	elif stats_card_category.stat_type == Constants.StatType.SPEED:
		target._speed += stats_card_category.change_value
	
	super.after_card_is_played(card_resource, event_categories)
