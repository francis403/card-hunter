extends Resource
class_name StateCondition

enum StateConditionEnum {
	ALWAYS,
	RANGE_TO_PLAYER,
	SELF_HP_PERCENTANGE,
	AFTER_X_TURNS,
	ON_PLAYER_HIT
}

@export var state_condition: StateConditionEnum
@export var logical_operation: Constants.LogicalOperationEnum
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
		StateConditionEnum.ON_PLAYER_HIT:
			return on_player_hit_condition(current_state)
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
	return logical_operation_comparison(value)

func logical_operation_comparison(y: int) -> bool:
	return Constants.logical_operation_comparison(
		logical_operation,
		x,
		y
	)
	
func on_player_hit_condition(
	_current_state: State
) -> bool:
	return _current_state.player_hit_during_turn
