extends Resource

## Configuration for weighted random state selection
class_name WeightedStateOption

## The state name to transition to
@export var state_name: String = ""
## The weight for this state (higher = more likely)
@export var weight: float = 1.0
