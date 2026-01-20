extends Node

enum EventID {
	THANK_YOU,
	NEW_WORLD,
}

var EVENT_CONFIGS: Dictionary = {
	EventID.THANK_YOU: Refs.thank_you_event_scene,
	EventID.NEW_WORLD: Refs.new_village_event_scene,
}

var _current_event_id: EventID

func show_event(
	event_id: EventID,
	parent: Node = null
) -> EventSubScreen:
	var config: EventConfig = EVENT_CONFIGS.get(event_id)
	if not config:
		push_error("EventController: No config found for event_id: ", event_id)
		return null
	_current_event_id = event_id
	var screen: EventSubScreen = Refs.event_subscreen.instantiate()
	screen.setup_with_config(config)

	var target_parent = parent if parent else get_tree().root
	target_parent.add_child(screen)

	return screen
