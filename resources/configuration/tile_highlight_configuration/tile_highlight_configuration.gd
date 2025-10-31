extends Resource

## Configuration class that determines which tile's should be highlighted based
class_name TileHighlightConfig

@export var _range: int = 1
@export var min_range: float = 0
@export var area_type: Constants.AreaType = Constants.AreaType.INHERIT
@export var ignore_occupied_tiles: bool = false
@export var ignore_origin: bool = true
@export var ignore_corners: bool = false
@export var ignore_non_corners: bool = false
@export var ignore_tiles_with_effects: bool = false

@export_group("Specific directions")
@export var ignore_north_tiles: bool = false
@export var ignore_south_tiles: bool = false
@export var ignore_east_tiles: bool = false
@export var ignore_west_tiles: bool = false

@export_group("Specific tile location configs")
@export var use_specific_tile_location_config: bool = false
@export var ignore_tiles_close_to_origin: bool = false
@export var ignore_tiles_away_from_origin: bool = false
@export var ignore_tiles_same_distance_from_origin: bool = false

var is_tile_attacked: bool = false
var make_tile_clickable: bool = true

## Used in the Specific Tile Location Configs
var origin_tile: Tile = null
var target_tile: Tile = null


func _specific_tile_location_config_match(_tile: Tile) -> bool:
	if not origin_tile or not target_tile:
		return false
	if not self.use_specific_tile_location_config:
		return false
	var origin_target_distance: int = MovementUtils.distance_between_tiles(origin_tile, target_tile)
	#var origin_tile_distance: int = MovementUtils.distance_between_tiles(origin_tile, _tile)
	var origin_tile_distance: int = MovementUtils.distance_between_tiles(target_tile, _tile)
	
	if self.ignore_tiles_close_to_origin and origin_target_distance > origin_tile_distance:
		return true
	if self.ignore_tiles_away_from_origin and origin_target_distance < origin_tile_distance:
		return true
	if self.ignore_tiles_same_distance_from_origin and origin_target_distance == origin_tile_distance:
		return true
	return false
