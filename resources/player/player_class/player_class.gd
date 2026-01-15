extends Resource
class_name PlayerClass


enum UnlockConditionEnum {
	NUMBER_OF_BOSSES_DEFEATED
}


@export var player_class_name: String
@export var player_class_icon: AtlasTexture
@export var default_class_deck: PlayerDeck
@export_multiline var description: String

## TODO: make a configuration file for this
@export_group("Unlock Configurations - only valid if it starts locked")
@export var start_locked: bool = false
@export var unlock_condition: UnlockConditionEnum
@export var logical_op: Constants.LogicalOperationEnum
@export var value: int

func is_unlock_condition_encountered() -> bool:
	if not start_locked:
		return true
	var meta_value: int = -1
	match unlock_condition:
		UnlockConditionEnum.NUMBER_OF_BOSSES_DEFEATED:
			meta_value = File.meta_progress.number_of_bosses_defeated
	var _result: bool = meta_value >= 0 and Constants.logical_operation_comparison(
			logical_op,
			value,
			meta_value
	)
	return _result
