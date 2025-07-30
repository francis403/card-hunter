extends StateWithMovement
class_name ChargeState

@export var _range: int = 6
@export var state_after_charging: String

var has_highleted_charge_tiles: bool = false
var next_turn_move_tile: Tile = null

func enter_state():
	super.enter_state()
	print(enter_state)
	self.do_state_action()
	
func do_state_action():
	super.do_state_action()
	print(do_state_action)
	if not has_highleted_charge_tiles:
		_highlight_charge_tiles()
		return
	charge()
	self.changed_state.emit(self, state_after_charging)

func _highlight_charge_tiles():
	# clean old attacked tiles
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	var source_tile: Tile = monster._tile
	var config: TileHighlightConfig = TileHighlightConfig.new()
	config.area_type = Constants.AreaType.CROSS
	config.range = _range
	
	if target._tile._x_position < monster._tile._x_position:
		config.ignore_east_tiles = true
	if target._tile._x_position > monster._tile._x_position:
		config.ignore_west_tiles = true
		
	if target._tile._y_position > monster._tile._y_position:
		config.ignore_south_tiles = true
	elif target._tile._y_position < monster._tile._y_position:
		config.ignore_north_tiles = true
	else:
		config.ignore_north_tiles = true
		config.ignore_south_tiles = true
	next_turn_move_tile = MovementUtils.get_movement_tile(
		monster._tile,
		target._tile,
		_range
	)
	
	BattlemapSignals.highlight_attack_tiles.emit(
		source_tile,
		config
	)
	has_highleted_charge_tiles = true

	
func charge():
	BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
