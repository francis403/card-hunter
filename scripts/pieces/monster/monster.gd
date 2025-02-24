extends Piece
class_name Monster

#TODO: need to do some sort of array of possible attacks

func apply_damage(damage: int):
	self._health -= damage
	if _health <= 0:
		_die()
		
		
func _die():
	self._tile.piece_in_tile = null
	queue_free()
