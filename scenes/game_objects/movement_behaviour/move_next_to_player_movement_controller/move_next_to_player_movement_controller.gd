extends MovementBehaviour
class_name MoveNextToPlayerMovementController

var next_turn_move_tile: Tile
var monster: MonsterPiece
var monster_sprite: Sprite2D

func do_movement():
	print(do_movement)
	if not monster:
		monster = BattleController.get_monster()
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	if monster_sprite:
		monster_sprite.queue_free()
	monster_sprite = monster.get_sprite().duplicate()
	next_turn_move_tile = get_movement_tile()
	BattlemapSignals.monster_prepared_move.emit(
		monster_sprite,
		next_turn_move_tile
	)


# By default go speed up to player and end up next to him
func get_movement_tile() -> Tile:
	
	var monster = BattleController.get_monster()
	var player_tile: Tile = BattleController.get_player()._tile
	var monster_tile: Tile = monster._tile
	
	var x = monster_tile._x_position
	var y = monster_tile._y_position
	var moved_tiles: int = 0
	var distance_to_player: int = BattleController.distance_between_tiles(
		player_tile, monster_tile
	)
	
	while (moved_tiles < monster._speed && distance_to_player > 1):
		if player_tile._x_position > x:
			x += 1
			distance_to_player -= 1
		elif player_tile._x_position < monster_tile._x_position:
			x -=  1
			distance_to_player -= 1
		if player_tile._y_position > y:
			y += 1
			distance_to_player -= 1
		elif player_tile._y_position < y:
			y -= 1
			distance_to_player -= 1
		moved_tiles += 1
	return BattleController.get_tile(x, y)
