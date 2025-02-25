extends Piece
class_name MonsterPiece

#TODO: need to do some sort of array of possible attacks

func play_monster_turn():
	pass

func end_monster_turn():
	BattlemapSignals.player_turn_started.emit()

func apply_damage(damage: int):
	self._health -= damage
	if _health <= 0:
		_die()
		
		
func _die():
	self._tile.piece_in_tile = null
	queue_free()
	
# By default go speed up to player and end up next to him
func get_movement_tile() -> Tile:
	var player_tile: Tile = BattleController.get_player()._tile
	var monster_tile: Tile = BattleController.get_monster()._tile
	
	var x = monster_tile._x_position
	var y = monster_tile._y_position
	var moved_tiles: int = 0
	var distance_to_player: int = BattleController.distance_between_tiles(
		player_tile, monster_tile
	)
	
	while (moved_tiles < self._speed && distance_to_player > 1):
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
