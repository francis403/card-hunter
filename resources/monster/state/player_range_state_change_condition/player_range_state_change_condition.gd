extends StateChangeCondtion
class_name PlayerRangeStateChangeCondition

@export_group("Change value of x for all behaviours")
@export var common_x: int = 0
@export var use_monster_range: bool = false

@export_group("States to Transition names")
@export var bigger_than_state: String = ""
@export var equal_state: String = ""
@export var smaller_than_state: String = ""


func change_state_if_condition_applies(
	monster: GenericMonster,
	current_state: State
) -> bool:
	var range_conditions: Array[StateCondition] = get_range_conditions()
	if range_conditions[0].is_condition_matched(monster, current_state):
		current_state.changed_state.emit(current_state, bigger_than_state)
		return true
	if range_conditions[1].is_condition_matched(monster, current_state):
		current_state.changed_state.emit(current_state, equal_state)
		return true
	if range_conditions[2].is_condition_matched(monster, current_state):
		current_state.changed_state.emit(current_state, smaller_than_state)
		return true
	return super.change_state_if_condition_applies(monster, current_state)


func get_range_conditions() -> Array[StateCondition]:
	var result: Array[StateCondition] = []
	var condition_bigger_than: StateCondition = StateCondition.new()
	var condition_equal: StateCondition = StateCondition.new()
	var condition_smaller_than: StateCondition = StateCondition.new()
	
	condition_bigger_than.x = common_x
	condition_bigger_than.logical_operation = StateCondition.LogicalOperationEnum.BIGGER_THAN
	condition_bigger_than.state_condition = StateCondition.StateConditionEnum.RANGE_TO_PLAYER
	
	condition_equal.x = common_x
	condition_equal.logical_operation = StateCondition.LogicalOperationEnum.EQUAL
	condition_equal.state_condition = StateCondition.StateConditionEnum.RANGE_TO_PLAYER
	
	condition_smaller_than.x = common_x
	condition_smaller_than.logical_operation = StateCondition.LogicalOperationEnum.SMALLER_THAN
	condition_smaller_than.state_condition = StateCondition.StateConditionEnum.RANGE_TO_PLAYER
	
	result.append(condition_bigger_than)
	result.append(condition_equal)
	result.append(condition_smaller_than)
	return result
	
#func change_state_if_condition_applies(monster: GenericMonster, state: State) -> bool:
	#for conn
