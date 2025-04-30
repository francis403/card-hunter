extends EventCategory
class_name TileEffectCategoryCard

#@export var stat_type: Constants.Tile = Constants.StatType.HEALTH
@export var number_of_turns: int = 1

## TODO: is this smart or should I pass a config file?
@export var tile_effect_scene: PackedScene
