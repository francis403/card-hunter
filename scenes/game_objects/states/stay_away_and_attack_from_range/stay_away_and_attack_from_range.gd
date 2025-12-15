extends StateWithMovement
class_name StayAwayAndAttackFromRangeState

@export var _range: int = 2
	
	
func do_action():
	if monster.next_move:
		monster.next_move = null
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
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
