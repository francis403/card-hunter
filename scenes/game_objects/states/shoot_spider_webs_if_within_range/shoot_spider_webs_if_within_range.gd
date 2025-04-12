extends StateWithMovement

## If outside of attack range create some spiderwebs
class_name ShootSpiderWebsIfWithinRange

@export_category("General State Behaviour")
@export var webs_range: int = 2
@export var status_id: String = "stop_next_movement"
@export var tile_effect_type: Constants.TileEffectTypes = Constants.TileEffectTypes.SPIDER_WEB

@export_category("State Switch Behaviour")
@export var maximum_distance_to_player: int = 1
@export var out_of_range_state: String = "CreateSpiderWebsIfOutOfRange"

@export var min_distance_to_player: int = 1
@export var close_range_state: String = "MoveAndSingleAttackState"

@export var player_hit_state: String = "MoveAndSingleAttackState"

var target_tile: Tile = null
var is_player_hit: bool = false

func enter_state():
	super.enter_state()
	print(enter_state)
	target_tile = BattleController.get_player()._tile
	highlight_tile(target_tile)

func do_state_action():
	super.do_state_action()
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	
	BattlemapSignals.add_effect_type_to_tile.emit(
		tile_effect_type,
		target_tile
	)
	
	is_player_hit = target.has_status(status_id)
	
	## If player is hit, and we want to do something when player is hit
	if is_player_hit && player_hit_state:
		self.changed_state.emit(self, close_range_state)
		return
	## Oherwise, if player is not hit calculete the next target tile and behaviour
	# if we are in range do something else
	var distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	if distance_to_player > self.maximum_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, out_of_range_state)
		return

	if distance_to_player <= self.min_distance_to_player:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		self.changed_state.emit(self, close_range_state)
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
