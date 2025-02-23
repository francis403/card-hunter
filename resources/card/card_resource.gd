extends Resource
class_name CardResource

@export var id: String
@export var title: String
@export_multiline var description: String


@export var default_target: Constants.TargetType = Constants.TargetType.SELF
@export var default_area_type: Constants.AreaType = Constants.AreaType.NONE

@export var card_categories: Array[CardCategory] = []

# TODO: maybe I don't need a packed scene here
@export var card_ability_controller_scene: PackedScene
