extends StateWithMovement
class_name MovendSingleAttackState

@export var state_if_higher_than_max_range: String = ""
@export var max_range: int = 1
@export var highlight_config: TileHighlightConfig
	
func exit_state():
	pass
	
func enter_state():
	super.enter_state()
	print(enter_state)
	do_attack()
	
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
	
	self.do_attack()
	

func do_preview_action(recalculate_move: bool = false):
	self.preview_monster_attack_behaviour(recalculate_move)

func do_movement():
	var next_turn_move_tile: Tile = monster.next_move
	
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	next_turn_move_tile = MovementUtils.get_movement_tile(
		monster._tile,
		target._tile,
		monster._speed
	)
	BattlemapSignals.monster_prepared_move.emit(
		next_turn_move_tile
	)
	
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
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.RADIUS
	if highlight_config:
		config = highlight_config 
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		config
	)
