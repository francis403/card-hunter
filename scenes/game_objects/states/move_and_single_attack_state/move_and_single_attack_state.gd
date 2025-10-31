extends StateWithMovement
class_name MovendSingleAttackState

@export var state_if_higher_than_max_range: String = ""
@export var max_range: int = 1

## Attack shape
@export var highlight_config: TileHighlightConfig

## TODO: Maybe only calculate movement instead of always having to check in the action
func enter_state():
	super.enter_state()
	print(enter_state, ": ", self.name)
	self.do_state_action()
	
func do_state_action():
	super.do_state_action()
	
	var distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	
	# only show when able to attack player
	if distance_to_player > max_range:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, state_if_higher_than_max_range)
		return
	
	self.check_and_apply_state_change_action()
	
	self.do_attack()
	

func do_preview_action(recalculate_move: bool = false):
	self.preview_monster_attack_behaviour(recalculate_move)

func do_movement():
	var next_turn_move_tile: Tile = monster.next_move
	
	if next_turn_move_tile:
		##print("DEBUG: placing monster in: ", next_turn_move_tile.to_vector())
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	next_turn_move_tile = MovementUtils.get_movement_tile(
		monster._tile,
		target._tile,
		monster._speed
	)
	monster.next_move = next_turn_move_tile
	
func do_attack():
	preview_monster_attack_behaviour()

func preview_monster_attack_behaviour(recalculate_move: bool = false) -> void:
	if monster.next_move and recalculate_move:
		monster.next_move = null
		self.do_movement()
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	highlight_attack_tiles(source_tile)

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	highlight_config.origin_tile = monster._tile if not monster.next_move else monster.next_move
	highlight_config.target_tile = target._tile
	BattleController.battlemap.clear_highlighted_tiles()
	BattleController.battlemap.highlight_attack_tiles(source_tile, highlight_config)
