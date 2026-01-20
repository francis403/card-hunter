extends EventButtonAction
class_name OpenSceneEventButtonAction

## Opens a PackedScene (e.g., CardDeforge, other screens)

@export var scene_to_open: PackedScene
@export var add_to_root: bool = true
@export var close_event_after: bool = true

func execute(event_sub_screen: EventSubScreen) -> bool:
	if not scene_to_open:
		push_warning("OpenSceneEventButtonAction: No scene_to_open specified")
		return close_event_after

	var instance = scene_to_open.instantiate()

	if add_to_root:
		event_sub_screen.get_tree().root.add_child(instance)
	else:
		event_sub_screen.get_parent().add_child(instance)

	return close_event_after

func can_execute(_event_sub_screen: EventSubScreen) -> bool:
	return scene_to_open != null
