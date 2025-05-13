extends Resource
class_name StateCondition

enum StateConditionEnum {
	ALWAYS,
	RANGE_TO_PLAYER,
	SELF_HP_PERCENTANGE,
	AFTER_X_TURNS
}

enum LogicalOperationEnum {
	EQUAL,
	BIGGER_THAN,
	BIGGER_OR_EQUAL,
	SMALLER_THAN,
	SMALLER_OR_EQUAL,
	DIFFERENT_THAN
}

@export var state_condition: StateConditionEnum
@export var logical_operation: LogicalOperationEnum
@export var x: int = 0

func is_condition_matched(
	monster: GenericMonster,
	current_state: State
) -> bool:
	var result: bool = false
	match state_condition:
		StateConditionEnum.ALWAYS:
			return true
		StateConditionEnum.RANGE_TO_PLAYER:
			return distance_to_player_comparison(monster)
		StateConditionEnum.SELF_HP_PERCENTANGE:
			return monster_health_comparison(monster)
		StateConditionEnum.AFTER_X_TURNS:
			return logical_operation_comparison(current_state.number_of_active_turns)
	return result

func distance_to_player_comparison(
	monster: GenericMonster
) -> bool:
	var player: PlayerCharacter = BattleController.get_player()
	if not player:
		return false
	var distance_to_player: int = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		player._tile
	)
	return logical_operation_comparison(distance_to_player)
	
func monster_health_comparison(
	monster: GenericMonster
) -> bool:
	var value: float = (float (monster._health) / float(monster._max_hp)) * 100
	print(monster_health_comparison, " : ", value)
	return logical_operation_comparison(value)

func logical_operation_comparison(y: int) -> bool:
	match logical_operation:
		LogicalOperationEnum.EQUAL:
			return y == x
		LogicalOperationEnum.BIGGER_THAN:
			return y > x
		LogicalOperationEnum.BIGGER_OR_EQUAL:
			return y >= x
		LogicalOperationEnum.SMALLER_THAN:
			return y < x
		LogicalOperationEnum.SMALLER_OR_EQUAL:
			return y <= x
		LogicalOperationEnum.DIFFERENT_THAN:
			return y != x
	return false
