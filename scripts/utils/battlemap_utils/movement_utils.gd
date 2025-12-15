extends Node

func get_movement_tile(
	start_tile: Tile,
	target_tile: Tile,
	speed: int,
	_range: int = 1 
) -> Tile:
	var x = start_tile._x_position
	var y = start_tile._y_position
	var moved_tiles: int = 0
	var distance_to_player: int = distance_between_tiles(
		start_tile, 
		target_tile
	)
	
	if distance_to_player <= _range:
		return null
	
	while (moved_tiles < speed && distance_to_player > _range):
		if target_tile._x_position > x:
			x += 1
			distance_to_player -= 1
		elif target_tile._x_position < x:
			x -=  1
			distance_to_player -= 1
		if target_tile._y_position > y:
			y += 1
			distance_to_player -= 1
		elif target_tile._y_position < y:
			y -= 1
			distance_to_player -= 1
		moved_tiles += 1
	
	return BattleController.get_tile(x, y)

func move_away_from_tile(
	start_tile: Tile,
	tile_to_move_away: Tile,
	speed: int,
	optimal_distance: int = 100
) -> Tile:
	var x = start_tile._x_position
	var y = start_tile._y_position
	var moved_tiles: int = 0
	var current_distance: int = distance_between_tiles(
		start_tile, 
		tile_to_move_away
	)
	
	if current_distance >= optimal_distance:
		return null
	
	while (moved_tiles < speed && current_distance < optimal_distance):
		if tile_to_move_away._x_position > x:
			x -= 1
		elif tile_to_move_away._x_position < x:
			x +=  1
		if tile_to_move_away._y_position > y:
			y -= 1
		elif tile_to_move_away._y_position < y:
			y += 1
		current_distance += 1
		moved_tiles += 1
	return BattleController.get_tile(x, y)
	

func distance_between_tiles(tile1: Tile, tile2: Tile) -> int:
	var x1 = tile1._x_position
	var x2 = tile2._x_position
	var y1 = tile1._y_position
	var y2 = tile2._y_position
	return round(
		pow(
			pow((x2 - x1), 2) + pow((y2 - y1), 2),
			0.5
		)
	)
	
func is_tile_between(tile_to_check: Tile, origin_tile: Tile, target_tile: Tile) -> bool:
	if not tile_to_check or not origin_tile or not target_tile:
		return false
	
	if tile_to_check == origin_tile or tile_to_check == target_tile:
		return false
	
	var origin_to_target_distance = distance_between_tiles(origin_tile, target_tile)
	var origin_to_check_distance = distance_between_tiles(origin_tile, tile_to_check)
	var check_to_target_distance = distance_between_tiles(tile_to_check, target_tile)
	
	var total_distance_through_check = origin_to_check_distance + check_to_target_distance
	var threshold = 1.0
	
	return abs(total_distance_through_check - origin_to_target_distance) <= threshold

## Check if point a is between b and c
func is_between(a: Vector2, b: Vector2, c: Vector2) -> bool:
	# 1. Check if A is collinear with B and C using the 2D cross product (z-component)
	# (B - A) x (C - A) should be zero (or very close to zero for floats)
	var cross_product_z = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
	if abs(cross_product_z) > 0.0001: # Tolerance for float comparison
		return false # Not collinear

	# 2. Check if A lies within the B-C segment (on the line)
	# Dot product (A - B) . (C - B) should be positive, meaning A is in the direction of C from B
	# AND dot product (A - C) . (B - C) should be positive, meaning A is in the direction of B from C
	# (This ensures it's between B and C, not beyond C or B)
	var dot_ab_cb = (a - b).dot(c - b)
	var dot_ac_bc = (a - c).dot(b - c)

	return dot_ab_cb >= 0 and dot_ac_bc >= 0

func get_left_tile(tile: Tile):
	if not tile:
		return null
	return BattleController.get_tile(tile._x_position - 1, tile._y_position)
