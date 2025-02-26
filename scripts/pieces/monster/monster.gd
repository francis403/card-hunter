extends Piece
class_name MonsterPiece

#TODO: need to do some sort of array of possible attacks
var behaviour_deck = []

var move_tile: Tile = self._tile
var monster_sprite: Sprite2D = null

func play_monster_turn():
	pass

func end_monster_turn():
	preview_action()
	BattlemapSignals.player_turn_started.emit()

func apply_damage(damage: int):
	self._health -= damage
	if _health <= 0:
		_die()
		
		
func _die():
	self._tile.piece_in_tile = null
	if monster_sprite:
		monster_sprite.queue_free()
	if move_tile:
		move_tile.queue_free()
	queue_free()

func preview_action():
	move_tile = get_movement_tile()
	if monster_sprite:
		monster_sprite.queue_free()
	monster_sprite = get_sprite().duplicate()
	if not monster_sprite:
		print("no monster sprite found")
		return
	BattlemapSignals.monster_prepared_move.emit(monster_sprite, move_tile)
	
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

func get_sprite() -> Sprite2D:
	return null
#
#func get_witdh() -> int:
	#return 0
	#
#func get_height() -> int:
	#return 0
