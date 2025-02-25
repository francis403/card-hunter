extends MonsterPiece
class_name CrabMonster


func play_monster_turn():
	# move closer to the player by one
	print("Monster turn")
	
	_prepare_move()
	_prepare_attack()
	
	
	# send signal monster turn is over
	self.end_monster_turn()

# TODO: crab monster can just move in the general direction of the player until it attacks
func _prepare_move():
	var tile: Tile = BattleController.get_tile(
		self._tile._x_position - 1,
		self._tile._y_position
	)
	if not tile:
		print("No tile found for monster movement")
		return
		
	BattleController.battlemap.place_piece_in_tile(self, tile)
	
func _prepare_attack():
	pass
