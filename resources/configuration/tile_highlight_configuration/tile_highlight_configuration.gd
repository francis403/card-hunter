extends Resource

## Configuration class that determines which tile's should be highlighted based
class_name TileHighlightConfig

@export var _range: int = 1
@export var min_range: float = 0
@export var area_type: Constants.AreaType = Constants.AreaType.INHERIT
@export var include_target_tile_by_default: bool = false
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
@export var ignore_tiles_not_inbetween_origin_and_target: bool = false
@export var ignore_tiles_same_distance_from_origin: bool = false
@export_group("Monster orientation configs")
## Should the monster only attack in the players general direction
@export var ignore_tiles_opposite_target_orientation:  bool = false
## Should the monster only attack opposite of the players general direction
@export var ignore_tiles_in_target_orientation:  bool = false
## Use a range instead of just general direction or not. 
## Range 0 is a line
@export var use_range_tile_player_orientation:  bool = false

@export_group("Origin - Target Direction config")
## Use only tiles the same direction (vector) between origin and target.
## Accepts given range
@export var origin_target_direction_tiles_only: bool = false
@export var direction_accepted_range: float = 0.1

@export_group("Special Tile Highlight configuration")
## Is a formula to be used to create more complex patterns.
## (0, 0) is the origin tile, and (0, 1) will be the tile up from the origin tile
## Available variables:
## x -> relative x position to origin tile
## y -> relative y position to origin tile
## p_x -> player_x relative to origin tile
## p_y -> player_y relative to origin tile
## m_x -> monster_x relative to origin tile
## m_y -> monster_y relative to origin tile
## d_p_t -> total distance to player relative to (x, y)
@export var formulas: Array[Formula] = []

@export_group("Debug Config")
@export var enable_debug: bool = false

var is_tile_attacked: bool = false
var make_tile_clickable: bool = true

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
	#if GameController.debug_mode_enabled:
	if enable_debug:
		print("DEBUG: checking ", _tile.to_vector())
	if self.ignore_origin and _radius_distance == 0:
		GeneralUtils.debug_log("DEBUG:  ignoring origin", enable_debug)
		return false
	if self.include_target_tile_by_default and\
		target_tile and _tile.to_vector() == target_tile.to_vector():
		GeneralUtils.debug_log("DEBUG:  including target tile", enable_debug)
		return true
	if self.ignore_occupied_tiles and _tile.is_occupied():
		return false
	if furthest_square_distance <= self.min_range :
		return false
	if self.ignore_corners and _radius_distance > self._range:
		GeneralUtils.debug_log("DEBUG:  ignoring corners", enable_debug)
		return false
	if self.ignore_non_corners and abs(_radius_x) != abs(_radius_y):
		GeneralUtils.debug_log("DEBUG:  ignoring non-corners", enable_debug)
		return false
	if self.ignore_tiles_with_effects and _tile.has_effect():
		GeneralUtils.debug_log("DEBUG:  ignoring tile with effects", enable_debug)
		return false
	if self._specific_tile_location_config_match(_tile):
		GeneralUtils.debug_log(
			"DEBUG: ignoring due to specific_tile_location config %s" % _tile.to_vector(),
			enable_debug
		)
		return false
	if self._should_ignore_tile_based_on_orientation(_tile):
		GeneralUtils.debug_log(
			"DEBUG: ignoring due to orientation %s" % _tile.to_vector(),
			enable_debug
		)
		return false
	if not self._is_point_in_direction_range(
		_tile
	):
		GeneralUtils.debug_log(
			"DEBUG: ignoring due to not pointing in right direction",
			enable_debug
		)
		return false
	if not _is_point_in_formulas(
		_origin_tile.to_vector(),
		_radius_distance_from_origin
	):
		GeneralUtils.debug_log(
			"DEBUG: ignoring due to not in formula",
			enable_debug
		)
		return false
	if enable_debug:
		print("DEBUG: Found tile ", _tile.to_vector())
	return true

func _specific_tile_location_config_match(
	_tile: Tile
) -> bool:
	if not origin_tile or not target_tile:
		return false
	if not self.use_specific_tile_location_config:
		return false
	var _x_tile: Vector2 = _tile.to_vector()
	var _o_tile: Vector2 = origin_tile.to_vector()
	var _t_tile: Vector2 = target_tile.to_vector()
	
	var _o_t_distance: int = MovementUtils.distance_between_tiles(origin_tile, target_tile)
	var _o_x_distance: int = MovementUtils.distance_between_tiles(origin_tile, _tile)
	var _t_x_distance: int = MovementUtils.distance_between_tiles(target_tile, _tile)
	var _t_o_distance: int = MovementUtils.distance_between_tiles(target_tile, origin_tile)
	
	var _is_tile_away_from_origin: bool =\
		_o_t_distance < _o_x_distance and _o_x_distance > _t_x_distance
	var _is_tile_close_from_origin: bool =\
		_t_x_distance > _o_x_distance and _t_o_distance < _t_x_distance
	var _is_tile_equal_distance_from_origin: bool =\
		_o_x_distance == _t_x_distance
	var _is_tile_inbetween_origin_and_target: bool =\
		_o_t_distance > _o_x_distance and _t_x_distance  < _t_o_distance  
	
	if self.ignore_tiles_close_to_origin and _is_tile_close_from_origin:
		return true
	if self.ignore_tiles_away_from_origin and _is_tile_away_from_origin:
		return true
	if self.ignore_tiles_same_distance_from_origin and _is_tile_equal_distance_from_origin:
		return true
	if self.ignore_tiles_not_inbetween_origin_and_target and not _is_tile_inbetween_origin_and_target:
		return true
	return false

func _is_point_in_direction_range(
	_tile: Tile
) -> bool:
	if not self.origin_target_direction_tiles_only:
		return true
	var _result: bool = false
	var _tile_vector: Vector2 = _tile.to_vector()
	var _origin_vector: Vector2 = origin_tile.to_vector()
	var _target_vector: Vector2 = target_tile.to_vector()
	var _origin_to_target_direction: Vector2 = _origin_vector.direction_to(_target_vector)
	var _tile_to_target_direction: Vector2 = _tile_vector.direction_to(_target_vector)
	var _total_distance: float = _origin_to_target_direction.distance_to(_tile_to_target_direction)
	_result = _total_distance <= direction_accepted_range
	return _result
	
## If true ignore tile
func _should_ignore_tile_based_on_orientation(
	_tile: Tile
) -> bool:
	var _tile_vector: Vector2 = _tile.to_vector()
	if not origin_tile or not target_tile:
		return false
	var _origin_vector: Vector2 = origin_tile.to_vector()
	var _target_vector: Vector2 = target_tile.to_vector()
	var tiles_are_opposite_orientation: bool =\
		origin_tile.is_other_opposite_direction_to_self(_tile, _target_vector)
	
	if ignore_tiles_opposite_target_orientation and not tiles_are_opposite_orientation:
		return true
	if ignore_tiles_in_target_orientation and tiles_are_opposite_orientation:
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
