extends StateChangeCondtion
class_name PlayerRangeStateChangeCondition

@export_group("Change value of x for all behaviours")
## If you want to use a common x for all behaviours change this to not be a negative value
@export var common_x: int = -1

## Top Range for the equal behaviour ("Leave blank to stay in the same state").
## Only used if common_x is > 0
@export var top_range_for_equal_behaviour: int = 0
## Low Range for the equal behaviour ("Leave blank to stay in the same state")
## Only used if common_x is > 0
@export var low_range_for_equal_behaviour: int = 0

@export_group("Timing for the player range check")
## Run before other conditions. If false is checked after
@export var run_other_conditions_before: bool = false

@export_group("States to Transition names")
@export var bigger_than_state: String = ""
@export var equal_state: String = ""
@export var smaller_than_state: String = ""


func change_state_if_condition_applies(
	monster: GenericMonster,
	current_state: State
) -> bool:
	var result: bool = false
	if run_other_conditions_before:
		result = super.change_state_if_condition_applies(monster, current_state)
		if result:
			return true
	var range_conditions: Array[StateCondition] = get_range_conditions()
	if range_conditions[0].is_condition_matched(monster, current_state):
		return _change_state(current_state, bigger_than_state)
	if range_conditions[1].is_condition_matched(monster, current_state):
		return _change_state(current_state, equal_state)
	if range_conditions[2].is_condition_matched(monster, current_state):
		return _change_state(current_state, smaller_than_state)
	if not run_other_conditions_before:
		return super.change_state_if_condition_applies(monster, current_state)
	return false

func _change_state(
	current_state: State,
	state_to_transfer: String
) -> bool:
	if state_to_transfer.is_empty():
		return false
	current_state.changed_state.emit(current_state, state_to_transfer)
	return true

func get_range_conditions() -> Array[StateCondition]:
	var result: Array[StateCondition] = []
	var condition_bigger_than: StateCondition = StateCondition.new()
	var condition_equal: StateCondition = StateCondition.new()
	var condition_smaller_than: StateCondition = StateCondition.new()
	
	var bigger_than_x: int = common_x if common_x > 0 else top_range_for_equal_behaviour
	var smaller_than_x: int = common_x if common_x > 0 else low_range_for_equal_behaviour
	
	condition_bigger_than.x = bigger_than_x
	condition_bigger_than.logical_operation = StateCondition.LogicalOperationEnum.BIGGER_THAN
	condition_bigger_than.state_condition = StateCondition.StateConditionEnum.RANGE_TO_PLAYER
	
	condition_equal.x = common_x
	condition_equal.logical_operation = StateCondition.LogicalOperationEnum.EQUAL
	condition_equal.state_condition = StateCondition.StateConditionEnum.RANGE_TO_PLAYER
	
	condition_smaller_than.x = smaller_than_x
	condition_smaller_than.logical_operation = StateCondition.LogicalOperationEnum.SMALLER_THAN
	condition_smaller_than.state_condition = StateCondition.StateConditionEnum.RANGE_TO_PLAYER
	
	result.append(condition_bigger_than)
	result.append(condition_equal)
	result.append(condition_smaller_than)
	return result
	
#func change_state_if_condition_applies(monster: GenericMonster, state: State) -> bool:
	#for conn
