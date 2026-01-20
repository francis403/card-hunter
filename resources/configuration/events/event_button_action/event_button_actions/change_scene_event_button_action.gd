extends EventButtonAction
class_name ChangeSceneEventButtonAction

## Full scene transition (replaces entire scene tree)

@export var scene_to_change_to: PackedScene

func execute(event_sub_screen: EventSubScreen) -> bool:
	if not scene_to_change_to:
		push_warning("ChangeSceneEventButtonAction: No scene_to_change_to specified")
		return true

	event_sub_screen.get_tree().change_scene_to_packed(scene_to_change_to)
	return false  # Don't close, we're changing scenes

func can_execute(_event_sub_screen: EventSubScreen) -> bool:
	return scene_to_change_to != null
