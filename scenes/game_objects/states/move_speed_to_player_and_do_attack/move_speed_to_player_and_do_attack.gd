extends StateWithMovement
class_name MoveSpeedToPlayerAndDoAttack

## If 
@export var state_if_outside_range: String = "StayAwayAndAttackFromRange"
@export var _range: int = 1
	
## Defines which tiles to highlight for the attack
@export var tile_highlight_config: TileHighlightConfig
		
func do_action():
	var source_tile: Tile = monster.next_move
	if not source_tile:
		source_tile = monster._tile
	highlight_attack_tiles(source_tile)
	
func do_calculate_next_action() -> bool:
	if distance_to_player > _range:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, state_if_outside_range)
		return true
	return super.do_calculate_next_action()

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.RADIUS
	BattleController.battlemap.highlight_attack_tiles(source_tile, config)
