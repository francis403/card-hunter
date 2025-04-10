extends Resource

## Configuration class that determines which tile's should be highlighted based
class_name TileHighlightConfig

@export var range: int = 1
@export var min_range: float = 0
@export var area_type: Constants.AreaType = Constants.AreaType.INHERIT
@export var ignore_occupied_tiles: bool = false
@export var ignore_origin: bool = true
@export var ignore_corners: bool = false

var is_tile_attacked: bool = false
var make_tile_clickable: bool = true
