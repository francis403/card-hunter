extends StateWithMovement
class_name MoveSpeedToPlayerAndDoRadiusAttack

@export var change_state: String = "StayAwayAndAttackFromRange"
@export var _range: int = 1

var melee_attack_icon = self.state_icon

func do_action():
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	highlight_attack_tiles(source_tile)

func do_calculate_next_action() -> bool:
	# only show when able to attack player
	if distance_to_player > 1:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		monster.set_state_icon(MOVE_ICON)
		return false
	return super.do_calculate_next_action()

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.RADIUS
	BattleController.battlemap.highlight_attack_tiles(source_tile, config)
