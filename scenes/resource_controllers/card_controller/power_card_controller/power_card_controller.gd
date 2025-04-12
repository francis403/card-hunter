extends CardController
class_name PowerCardController


func play_card_action(
	card_resource: CardResource, 
	event_categories: EventCategoryDictionary = null
):
	super.play_card_action(card_resource, event_categories)
	print(play_card_action)
	if not event_categories.has_category("power"):
		print("ERROR: No power info in card")
	var power_card_category: PowerCategoryCard = event_categories.get_category("power")
	var target: Piece = get_piece(card_resource, power_card_category)
	#StatusEffect
	var power_controller_instance: Node = power_card_category.power_controller.instantiate()
	if not power_controller_instance is StatusEffect:
		print("power controller is not a status effect!")
		return
	var status_effect_instance: StatusEffect = power_controller_instance
	status_effect_instance.status_effect_config = power_card_category.status_event_config
	target.add_status(status_effect_instance)
	#status_effect_instance.on_effect_gain()

	super.after_card_is_played(card_resource, event_categories)
