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

@export_group("Special Tile Highlight configuration")
@export var formulas: Array[Formula] = []

var is_tile_attacked: bool = false
var make_tile_clickable: bool = true

## Used in the Specific Tile Location Configs
var origin_tile: Tile = null
var target_tile: Tile = null

## Given a tile position _tile_position
## & the difference between the current tile and the origin tile
## Return if the tile is valid based on the configuration
func is_tile_valid(
	_origin_tile: Tile,
	_radius_distance_from_origin: Vector2 = Vector2(0, 0)
) -> bool:
	var _radius_x: int = _radius_distance_from_origin.x
	var _radius_y: int = _radius_distance_from_origin.y
	var _radius_distance: int = abs(_radius_x) + abs(_radius_y)
	var furthest_square_distance: int = max(abs(_radius_x), abs(_radius_y))
	var _tile: Tile = BattleController.get_tile(
		_origin_tile._x_position + _radius_x,
		_origin_tile._y_position + _radius_y
	)
	if not _tile:
		return false
	if self.ignore_origin and _radius_distance == 0:
		return false
	if furthest_square_distance <= self.min_range :
		return false
	if self.ignore_corners and _radius_distance > self._range:
		return false
	if self.ignore_non_corners and abs(_radius_x) != abs(_radius_y):
		return false
	if self.ignore_tiles_with_effects and _tile.has_effect():
		return false
	if self._specific_tile_location_config_match(_tile):
		return false
	if not _is_point_in_formulas(
		_origin_tile.to_vector(),
		_radius_distance_from_origin
	):
		return false
	return true

func _specific_tile_location_config_match(
	_tile: Tile
) -> bool:
	if not origin_tile or not target_tile:
		return false
	if not self.use_specific_tile_location_config:
		return false
	var origin_and_target_distance: int = MovementUtils.distance_between_tiles(origin_tile, target_tile)
	#var origin_tile_distance: int = MovementUtils.distance_between_tiles(origin_tile, _tile)
	var target_and_tile_distance: int = MovementUtils.distance_between_tiles(target_tile, _tile)
	
	if self.ignore_tiles_close_to_origin and origin_and_target_distance > target_and_tile_distance:
		return true
	if self.ignore_tiles_away_from_origin and origin_and_target_distance < target_and_tile_distance:
		return true
	## TODO(FIX): I think there is a bug here
	if self.ignore_tiles_same_distance_from_origin and origin_and_target_distance == target_and_tile_distance:
		return true
	return false
	
## The point needs to be in relation to the origin tile
func _is_point_in_formulas(
	_origin_point: Vector2,
	_relative_point: Vector2
) -> bool:
	var _player_tile: Tile = BattleController.get_player()._tile
	var _player_pos: Vector2 = Vector2(-100, -100)
	if _player_tile:
		_player_pos = _player_tile.to_vector()
	var _relative_player_position: Vector2 = _player_pos - _origin_point
	for _formula in formulas:
		if not _formula.is_point_in_formula(_relative_point, _relative_player_position):
			return false
	return true
