extends MonsterPiece
class_name CrabMonster

@onready var sprite_2d: Sprite2D = $Sprite2D


func play_monster_turn():
	# move closer to the player by one
	
	_prepare_move()
	_prepare_attack()
	
	# send signal monster turn is over
	self.end_monster_turn()

func _prepare_move():
	var tile: Tile = self.move_tile
	if not tile:
		tile = get_movement_tile()
	if not tile:
		print("No tile found for monster movement")
		return
		
	BattleController.battlemap.place_piece_in_tile(self, tile)
	
func _prepare_attack():
	pass
	
func get_sprite() -> Sprite2D:
	return sprite_2d
