extends StateWithMovement

## If outside of attack range create some spiderwebs
class_name CreateSpiderWebsIfOutsideOfRange

@export var create_webs_range: int = 2
@export var maximum_distance_to_player: int = 2

var target_tile: Tile = null

func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)

func enter_state():
	super.enter_state()
	if not monster._tile:
		return
	print(enter_state)
	target_tile = await _get_next_random_tile()
	highlight_tile(target_tile)

func _on_battle_start_signal():
	print(_on_battle_start_signal)
	target_tile = await _get_next_random_tile()
	highlight_tile(target_tile)

func do_state_action():
	super.do_state_action()
	print(do_state_action)
	
	BattlemapSignals.clear_attack_highlight_tiles.emit()

	## if we start having a tile to add, add it there
	if target_tile:
		BattlemapSignals.add_effect_type_to_tile.emit(
			Constants.TileEffectTypes.SPIDER_WEB,
			target_tile
		)

	## if we are in range do something else
	var distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	if distance_to_player <= self.maximum_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, "ShootSpiderWebsIfWithinRangeState")
		return

	## get next target_tile and highlight
	target_tile = await _get_next_random_tile()
	highlight_tile(target_tile)

## TODO: on battle start this is not working well
func _get_next_random_tile() -> Tile:
	var tile_hightlight_configuration: TileHighlightConfig = TileHighlightConfig.new()
	tile_hightlight_configuration.area_type = Constants.AreaType.RADIUS
	tile_hightlight_configuration.range = create_webs_range
	tile_hightlight_configuration.ignore_tiles_with_effects = true
	BattlemapSignals.get_monster_range_tiles.emit(monster._tile, tile_hightlight_configuration)
	var tiles: Array[Tile] = await BattlemapSignals.monster_range_tiles_generated
	
	if tiles.is_empty():
		return null
	
	return tiles.pick_random()

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
