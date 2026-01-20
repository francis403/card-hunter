extends EventButtonAction
class_name CloseGameEventButton

## Completely closes the game
@export var delete_current_progress: bool = false

func execute(_event_sub_screen: EventSubScreen) -> bool:
	if delete_current_progress:
		File.delete_current_run_progress()
	File.save()
	_event_sub_screen.get_tree().quit()
	return false  # Don't close, we're changing scenes

func can_execute(_event_sub_screen: EventSubScreen) -> bool:
	return true
