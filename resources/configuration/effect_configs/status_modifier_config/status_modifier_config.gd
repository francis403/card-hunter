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
