extends Resource
class_name MonsterBehaviourResource

@export var id: String
@export var title: String
@export_multiline var description: String

@export var default_target: Constants.TargetType = Constants.TargetType.SELF
@export var default_area_type: Constants.AreaType = Constants.AreaType.NONE

## Define any extra data that might be needed by the movement & attack controller
@export var monster_behaviour_category_array: Array[EventCategory] = []

## Define monster attack for the specific behaviour
@export var attack_behaviour: PackedScene
