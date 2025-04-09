extends Resource
class_name EventCategory

@export var category_id: String
@export var target: Constants.TargetType = Constants.TargetType.INHERIT
@export var area_type: Constants.AreaType = Constants.AreaType.INHERIT

@export var configuration: TileHighlightConfig
