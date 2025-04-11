extends StateWithMovement

## If outside of attack range create some spiderwebs
class_name ShootSpiderWebsIfWithinRange

@export var webs_range: int = 2
@export var maximum_distance_to_player: int = 1


func do_state_action():
	super.do_state_action()

	var distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)

	# if we are in range do something else
	if distance_to_player > self.maximum_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, "CreteSpiderWebsIfOutOfRange")
		return

	if distance_to_player < self.maximum_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		return

	var player_tile: Tile = BattleController.get_player()._tile
	
	## TODO: highlight tile and then after the end of turn apply the spider web
	
	BattlemapSignals.add_effect_type_to_tile.emit(
		Constants.TileEffectTypes.SPIDER_WEB,
		player_tile
	)

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.RADIUS
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		config
	)
