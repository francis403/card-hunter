extends EventButtonAction
class_name PredefinedActionButton

enum PredefinedAction {
	generate_new_world
}

@export var predefined_action: PredefinedAction

func execute(
	_event_sub_screen: EventSubScreen
) -> bool:
	match predefined_action:
		PredefinedAction.generate_new_world:
			BattleSignals.world_generation_triggered.emit()
	return true
