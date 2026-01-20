extends Resource
class_name EventButtonAction

@export var id: String = ""

## Executes the button action
## Returns true if the event screen should close after execution
func execute(_event_sub_screen: EventSubScreen) -> bool:
	push_warning("EventButtonAction.execute() not implemented")
	return true

## Returns true if the action can be executed
func can_execute(_event_sub_screen: EventSubScreen) -> bool:
	return true
