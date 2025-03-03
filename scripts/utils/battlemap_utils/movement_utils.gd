extends Node

func get_movement_tile(
	start_tile: Tile,
	target_tile: Tile,
	speed: int
) -> Tile:
	var x = start_tile._x_position
	var y = start_tile._y_position
	var moved_tiles: int = 0
	var distance_to_player: int = BattleController.distance_between_tiles(
		start_tile, 
		target_tile
	)
	
	if distance_to_player <= 1:
		return null
	
	while (moved_tiles < speed && distance_to_player > 1):
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
