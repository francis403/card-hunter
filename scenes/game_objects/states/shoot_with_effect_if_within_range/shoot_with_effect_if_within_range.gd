extends StateWithMovement

## TODO: This will need to shoot a power effect instead
## If outside of attack range create some spiderwebs
class_name ShootSpiderWebsIfWithinRange

@export_category("General State Behaviour")
@export var _range: int = 2
## Deprecated: do not use
@export var status_id: String = "stop_next_movement"
@export var tile_effect_type: Constants.TileEffectTypes = Constants.TileEffectTypes.SPIDER_WEB

## TODO: Update to use this resource
@export var tile_effect_resource: TileEffectResource

@export_category("State Switch Behaviour")
@export var maximum_distance_to_player: int = 1
@export var out_of_range_state: String = "CreateSpiderWebsIfOutOfRange"

@export var min_distance_to_player: int = 1
@export var close_range_state: String = "MoveAndSingleAttackState"

@export var player_hit_state: String = "MoveAndSingleAttackState"

var target_tile: Tile = null
var is_player_hit: bool = false

func enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.enter_state()
	print(enter_state)
	target_tile = BattleController.get_player()._tile
	highlight_tile(target_tile)

func do_state_action(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.do_state_action()
	print(do_state_action)
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	if target_tile and tile_effect_resource.tile_effect_controller:
		var tile_effect_controller: BaseTileEffectController =\
			tile_effect_resource.tile_effect_controller.instantiate()
		tile_effect_controller.tile_effect_resource = self.tile_effect_resource
		target_tile.add_tile_effect_v2(
			tile_effect_controller
		)
	
	is_player_hit = target.has_power_effect(
		tile_effect_resource.power_effect.id
	)
	
	## If player is hit, and we want to do something when player is hit
	if is_player_hit && player_hit_state:
		print("is_player_hit && player_hit_state")
		if close_range_state != "":
			self.changed_state.emit(self, close_range_state)
			return
	## Oherwise, if player is not hit calculate the next target tile and behaviour
	var is_state_changed: bool = self.do_calculate_next_action()
	if is_state_changed:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		return

	target_tile = BattleController.get_player()._tile
	highlight_tile(target_tile)
	

func highlight_attack_tiles(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.RADIUS
	BattleController.battlemap.highlight_attack_tiles(source_tile, config)
	
func highlight_tile(source_tile: Tile):
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.ignore_origin = true
	config.area_type = Constants.AreaType.SPECIFIC
	BattleController.battlemap.highlight_attack_tiles(source_tile, config)
