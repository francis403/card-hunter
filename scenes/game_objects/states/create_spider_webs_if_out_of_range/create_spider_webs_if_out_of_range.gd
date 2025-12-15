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

func enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.enter_state()
	if not monster._tile:
		return
	target_tile = await _get_next_random_tile()
	highlight_tile(target_tile)

func _on_battle_start_signal():
	print(_on_battle_start_signal)
	target_tile = await _get_next_random_tile()
	highlight_tile(target_tile)

func do_movement():
	pass

func do_action():
	if target_tile:
		var tile_effect_controller: BaseTileEffectController =\
			tile_effect_resource.tile_effect_controller.instantiate()
		tile_effect_controller.tile_effect_resource = tile_effect_resource
		target_tile.add_tile_effect_v2(tile_effect_controller)
	
func do_calculate_next_action() -> bool:
	var is_state_changed: bool = super.do_calculate_next_action()
	if is_state_changed:
		return true
	## get next target_tile and highlight
	target_tile = _get_next_random_tile()
	highlight_tile(target_tile)
	return false

## TODO: on battle start this is not working well
func _get_next_random_tile() -> Tile:
	var tile_hightlight_configuration: TileHighlightConfig = TileHighlightConfig.new()
	tile_hightlight_configuration.area_type = Constants.AreaType.RADIUS
	tile_hightlight_configuration._range = create_webs_range
	tile_hightlight_configuration.ignore_tiles_with_effects = true
	tile_hightlight_configuration.make_tile_clickable = false
	var tiles: Array[Tile] = BattleController.get_range_tiles(monster._tile, tile_hightlight_configuration)
	if tiles.is_empty():
		return null
	return tiles.pick_random()

func highlight_tile(source_tile: Tile):
	# clean old attacked tiles
	BattleController.battlemap.clear_highlighted_tiles()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.ignore_origin = true
	config.area_type = Constants.AreaType.SPECIFIC
	BattleController.battlemap.highlight_attack_tiles(source_tile, config)
