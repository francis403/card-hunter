extends Piece
class_name MonsterPiece

func _ready() -> void:
	BattleSignals.battle_start.connect(on_battle_start_signal)

## Main function for the monster
func play_monster_turn():
	pass

func on_battle_start_signal():
	pass

## PLayed at the end of the monster turn
func end_monster_turn():
	BattlemapSignals.player_turn_started.emit()

func apply_damage(damage: int):
	self._health -= damage
	if _health <= 0:
		_die()
		
		
func _die():
	self._tile.piece_in_tile = null
	queue_free()

func get_sprite() -> Sprite2D:
	return null
