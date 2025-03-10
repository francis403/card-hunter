extends StateWithMovement
class_name StayAwayAndAttackFromRangeState

@export var range: int = 2


func exit_state():
	pass
	
func do_state_action():
	super.do_state_action()
	
	var distance_to_player = BattleController.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	# only show when able to attack player
	if distance_to_player > range:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		return
		
	self.do_attack()
	
func do_movement():
	var next_turn_move_tile: Tile = monster.next_move
	
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	if monster_sprite:
		monster_sprite.queue_free()
	monster_sprite = monster.get_sprite().duplicate()
	
	next_turn_move_tile = MovementUtils.move_away_from_tile(
		monster._tile,
		target._tile,
		monster._speed,
		range
	)
	
	BattlemapSignals.monster_prepared_move.emit(
		monster_sprite,
		next_turn_move_tile
	)
	
	self.changed_state.emit(self, "MoveSpeedToPlayerAndDoRadiusAttack")
	
func do_attack():
	do_preview_action()
	
## TODO: add this default fumction to the parent
func do_preview_action(recalculate_move: bool = false) -> void:
	if monster.next_move and recalculate_move:
		monster.next_move = null
		self.do_movement()
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	highlight_attack_tiles(source_tile)


func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		range,
		Constants.AreaType.CROSS
	)
