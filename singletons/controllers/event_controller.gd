extends Node

enum EventID {
	TUTORIAL_WELCOME,
	THANK_YOU,
	NEW_WORLD,
	BATTLE_TUTORIAL_COMPLETE
}

var EVENT_CONFIGS: Dictionary = {
	EventID.THANK_YOU: Refs.thank_you_event_scene,
	EventID.NEW_WORLD: Refs.new_village_event_scene,
	EventID.TUTORIAL_WELCOME: Refs.tutorial_welcome_event,
	EventID.BATTLE_TUTORIAL_COMPLETE: Refs.battle_tutorial_complete_event
}

func show_event(
	event_id: EventID,
	parent: Node = null
) -> EventSubScreen:
	var config: EventConfig = EVENT_CONFIGS.get(event_id)
	if not config:
		push_error("EventController: No config found for event_id: ", event_id)
		return null
	var screen: EventSubScreen = Refs.event_subscreen.instantiate()
	screen.setup_with_config(config)

	var target_parent = parent if parent else get_tree().root
	target_parent.add_child(screen)

	return screen
	
func show_event_via_resource(
	_event: EventConfig,
	_parent: Node = null
) -> EventSubScreen:
	#_current_event_id = 123
	var screen: EventSubScreen = Refs.event_subscreen.instantiate()
	screen.setup_with_config(_event)

	var target_parent = _parent if _parent else get_tree().root
	target_parent.add_child(screen)

	return screen
