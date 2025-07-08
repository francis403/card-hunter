extends Resource
class_name StateChangeCondtion

@export var conditions: Array[StateCondition] = []
@export var state_name: String

func change_state_if_condition_applies(
	monster: GenericMonster,
	current_state: State
) -> bool:
	for condition in conditions:
		if not condition.is_condition_matched(monster, current_state):
			return false
	if state_name != "":
		current_state.changed_state.emit(current_state, state_name)
		return true
	return false
