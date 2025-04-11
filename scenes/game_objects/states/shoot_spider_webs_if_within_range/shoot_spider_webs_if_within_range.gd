extends StateWithMovement

## If outside of attack range create some spiderwebs
class_name ShootSpiderWebsIfWithinRange

@export var webs_range: int = 2
@export var maximum_distance_to_player: int = 1
@export var min_distance_to_player: int = 1

var target_tile: Tile = null

func enter_state():
	super.enter_state()
	print(enter_state)
	target_tile = BattleController.get_player()._tile
	highlight_tile(target_tile)

func do_state_action():
	super.do_state_action()

	BattlemapSignals.clear_attack_highlight_tiles.emit()
	## TODO: do some damage
	if target_tile && not target_tile.has_effect():
		BattlemapSignals.add_effect_type_to_tile.emit(
			Constants.TileEffectTypes.SPIDER_WEB,
			target_tile
		)
	elif target_tile:
		## TODO: move up to the player and attack
		pass
	# if we are in range do something else
	var distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	if distance_to_player > self.maximum_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, "CreateSpiderWebsIfOutOfRange")
		return

	if distance_to_player <= self.min_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, "MoveAndSingleAttackState")
		return

	target_tile = BattleController.get_player()._tile
	highlight_tile(target_tile)
	

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.RADIUS
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		config
	)
	
func highlight_tile(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.ignore_origin = true
	config.area_type = Constants.AreaType.SPECIFIC
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		config
	)
