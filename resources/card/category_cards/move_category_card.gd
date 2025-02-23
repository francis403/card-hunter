extends CardCategory

# This card type has the info to move something
class_name MoveCategoryCard

@export var move_target: Constants.TargetType = Constants.TargetType.INHERIT
@export var move_distance: int = 1
