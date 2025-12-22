extends StateWithMovement
class_name MovendSingleAttackState

@export var state_if_higher_than_max_range: String = ""
@export var max_range: int = 1

## Attack shape
@export var highlight_config: TileHighlightConfig

func do_action():
	preview_monster_attack_behaviour()

func do_calculate_next_action() -> bool:
	if distance_to_player > max_range:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, state_if_higher_than_max_range)
		return true
	return super.do_calculate_next_action()

func preview_monster_attack_behaviour(recalculate_move: bool = false) -> void:
	if monster.next_move and recalculate_move:
		monster.next_move = null
		self.do_movement()
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	highlight_attack_tiles(source_tile)

func highlight_attack_tiles(source_tile: Tile):
	if not highlight_config:
		return
	# clean old attacked tiles
	highlight_config.origin_tile = monster._tile if not monster.next_move else monster.next_move
	highlight_config.target_tile = target._tile
	BattleController.battlemap.clear_highlighted_tiles()
	BattleController.battlemap.highlight_attack_tiles(source_tile, highlight_config)
