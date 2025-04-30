extends Resource

## This can be applied to:
## - Cards (on play)
## - Tile Effects
## - Status Effects
class_name StatusModifierConfig

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

@export var stat: Constants.StatType
@export var operation: Operation
@export var value: float = 1.0


func get_changed_value(stat_value: int) -> int:
	match operation:
		Operation.ADD:
			return stat_value + value
		Operation.SUBTRACT:
			return stat_value - value 
		Operation.MULTIPLY:
			return stat_value * value  
		Operation.DIVIDE:
			return stat_value / value 
	return stat_value
