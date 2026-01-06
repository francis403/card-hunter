extends Piece
class_name MonsterPiece

var next_move: Tile = null:
	set(value):
		next_move = value
		_on_move_intent_updated()

func _ready() -> void:
	BattleSignals.battle_start.connect(on_battle_start_signal)

## Main function for the monster
func play_monster_turn():
	pass

## Triggered when the battle is ready to start
func on_battle_start_signal():
	pass

func _on_move_intent_updated():
	pass

func on_monster_moved_by_player(_new_tile: Tile) -> void:
	pass

## PLayed at the end of the monster turn
func end_monster_turn():
	BattlemapSignals.player_turn_started.emit()

func apply_damage(
	damage: int,
	_origin_tile: Tile,
	_show_text: bool = true
):
	super.apply_damage(damage, _origin_tile, _show_text)
	BattlemapSignals.monster_hp_changed.emit(self._health, self._max_hp)

func _die():
	self._tile.piece_in_tile = null
	BattlemapSignals.monster_died.emit()
	queue_free()

func get_sprite() -> Sprite2D:
	return null

func highlight_attack_action() -> void:
	pass
