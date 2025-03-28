extends Node

func get_movement_tile(
	start_tile: Tile,
	target_tile: Tile,
	speed: int,
	range: int = 1 
) -> Tile:
	var x = start_tile._x_position
	var y = start_tile._y_position
	var moved_tiles: int = 0
	var distance_to_player: int = distance_between_tiles(
		start_tile, 
		target_tile
	)
	
	if distance_to_player <= range:
		return null
	
	while (moved_tiles < speed && distance_to_player > range):
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
