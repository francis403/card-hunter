extends StateWithMovement

## If outside of attack range create some spiderwebs
class_name CreateSpiderWebsIfOutsideOfRange

@export var create_webs_range: int = 2
@export var maximum_distance_to_player: int = 2

## TODO: Use this one
@export var tile_effect_resource: TileEffectResource

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
	
	BattlemapSignals.clear_attack_highlight_tiles.emit()

	## if we start having a tile to add, add it there
	if target_tile:
		var tile_effect_controller: BaseTileEffectController =\
			tile_effect_resource.tile_effect_controller.instantiate()
		tile_effect_controller.tile_effect_resource = tile_effect_resource
		target_tile.add_tile_effect_v2(tile_effect_controller)
		#BattlemapSignals.add_effect_type_to_tile.emit(
			#Constants.TileEffectTypes.SPIDER_WEB,
			#target_tile
		#)

	## if we are in range do something else
	var is_state_changed: bool = self.check_and_apply_state_change_action()
	if is_state_changed:
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
