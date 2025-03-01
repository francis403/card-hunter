extends Piece
class_name MonsterPiece

var next_move: Tile = null

func _ready() -> void:
	BattleSignals.battle_start.connect(on_battle_start_signal)
	BattlemapSignals.monster_prepared_move.connect(_on_monster_prepared_move_signal)
	BattlemapSignals.monster_moved_by_player.connect(on_monster_moved_by_player)

## Main function for the monster
func play_monster_turn():
	pass

func on_battle_start_signal():
	pass
	
func _on_monster_prepared_move_signal(sprite: Sprite2D, tile: Tile):
	next_move = tile

func on_monster_moved_by_player(new_tile: Tile) -> void:
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

func highlight_attack_action() -> void:
	pass
