extends StateWithMovement
class_name LurkState

## If left negative, uses monster speed
@export var _lurk_speed: int = -1

## Minimum distance to keep from target
@export var _min_distance_from_player: int = 2

## When keeping distance, there will always be two options. Pick one
#@export var _chance_of_going_left_of_target: float = .5

## We want to lurk, so we want to keep the same distance from the player
func do_calculate_next_move(
	_should_keep_same_movement_logic: bool = false
):
	if _should_keep_same_movement_logic:
		super.do_calculate_next_move(_should_keep_same_movement_logic)
		return
	if not target or not target._tile:
		return
	var _player_tile: Tile = target._tile
	var _origin_tile: Tile = monster._tile
	var _current_distance: int = MovementUtils.distance_between_tiles(
		_player_tile,
		monster._tile
	)
	var _possible_move_tiles: Array[Tile] = []
	var x: int = _origin_tile._x_position
	var y: int = _origin_tile._y_position
	var radius: int = _lurk_speed if _lurk_speed >= 0 else monster._speed
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _tile_x = x + radius_x
			var _tile_y = y + radius_y
			var _tile: Tile = BattleController.get_tile(_tile_x, _tile_y)
			if not _tile:
				continue
			if _tile.to_vector() == monster._tile.to_vector():
				continue
			var _distance: int =\
				MovementUtils.distance_between_tiles(_player_tile, _tile)
			if _distance < _current_distance\
				or _distance < _min_distance_from_player:
				continue
			if _current_distance >= _min_distance_from_player:
				if _distance == _current_distance:
					_possible_move_tiles.append(_tile)
			else:
				if _distance > _current_distance:
					_possible_move_tiles.append(_tile)
	monster.next_move = _possible_move_tiles.pick_random()
