extends StateWithMovement
class_name StayAwayAndAttackFromRangeState

@export var _range: int = 2


## This state keeps the monster stationary — it never moves on its own turn.
## Expressing "no movement" here (rather than in do_action) means
## do_action() never needs to touch monster.next_move at all, which prevents
## the pull-card preview from being silently clobbered.
func do_calculate_next_move(_should_keep_same_movement_logic: bool = false) -> Tile:
	return null


func do_action():
	# Use the monster's current tile as the attack origin.
	# monster.next_move is intentionally NOT modified here; it is the
	# responsibility of do_calculate_next_move() (above) to declare that
	# this state has no movement intent.
	var source_tile: Tile = monster._tile
	highlight_attack_tiles(source_tile)


func do_calculate_next_action() -> bool:
	if distance_to_player > _range:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		return false
	return super.do_calculate_next_action()


func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.CROSS
	config._range = _range
	BattleController.battlemap.highlight_attack_tiles(source_tile, config)