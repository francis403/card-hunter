extends State
class_name StateWithMovement

var target: PlayerPiece
var monster: GenericMonster

var distance_to_player: int = 0

## Conditions to change state
@export var state_change_conditions: Array[StateChangeCondtion]

func enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.enter_state()
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	monster.set_state_icon(state_icon)
	monster.next_move = null
	if not monster or not monster._tile:
		push_warning("Monster missconfiguration")
		return
	if _state_action_config.is_able_to_do_calculate_next_move:
		self.do_calculate_next_move()
	do_update_variables_after_movement()
	if _state_action_config.is_able_to_do_action:
		self.do_action()
	if _state_action_config.is_able_to_do_calculate_next_action:
		self.do_calculate_next_action()
	
func do_state_action(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.do_state_action()
	## Trigger any atacked tiles by the monster's previous attack
	if _state_action_config.is_able_to_do_trigger_previous_attacked_tiles:
		self.do_trigger_attacked_tiles()
	## Move the monster
	if _state_action_config.is_able_to_do_move:
		self.do_movement()
	if _state_action_config.is_able_to_do_calculate_next_move:
		self.do_calculate_next_move(
			_state_action_config.should_keep_same_movement_logic
		)
	self.do_update_variables_after_movement()
	## Do whatever the monster wants to do there
	if _state_action_config.is_able_to_do_action:
		self.do_action()
	if _state_action_config.is_able_to_do_attack:
		self.do_attack()
	## Calculate the monster's next action
	var _new_action: bool = false
	if _state_action_config.is_able_to_do_calculate_next_action:
		_new_action = self.do_calculate_next_action()

## -- Override this functions to define the behaviour --
func do_update_variables_after_movement():
	distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)

func do_trigger_attacked_tiles():
	BattlemapSignals.deal_damage_to_attacked_squares.emit(
		monster._tile,
		monster._strength
	)

func do_movement():
	if not monster:
		return
	var next_turn_move_tile: Tile = monster.next_move
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	
## Calculates the monster next move
## If _should_keep_same_movement_logic is true:
## - The direction the monster previously moved should be kept
## - If no direction, then no movement
func do_calculate_next_move(
	_should_keep_same_movement_logic: bool = false
):
	if not target or not monster:
		monster.next_move = null
		return
	## TODO
	if _should_keep_same_movement_logic:
		monster.next_move = _get_same_direction_monster_movement()
		return
	monster.next_move = MovementUtils.get_movement_tile(
		monster._tile,
		target._tile,
		monster._speed
	)
	
## Do any special actions
func do_action():
	pass
	
## Highlight any attack tiles
func do_attack():
	pass
	
func do_calculate_next_action() -> bool:
	return _check_and_apply_state_change_action()

##-----------

## Match first state condition found and switch to it
func _check_and_apply_state_change_action() -> bool:
	for state_change_condition in state_change_conditions:
		var is_state_changed: bool = state_change_condition.change_state_if_condition_applies(monster, self)
		if is_state_changed:
			return true
	return false

func _get_same_direction_monster_movement() -> Tile:
	if not monster or not monster.next_move:
		return null
	if not monster.previous_tile or not monster._tile :
		return null
	var _current_tile_vector: Vector2 = monster._tile.to_vector()
	var _previous_tile_vector: Vector2 = monster.previous_tile.to_vector()
	var _planned_move_tile_vector: Vector2 = monster.next_move.to_vector()
	var _distance: int = MovementUtils.distance_between_tiles(monster.previous_tile, monster.next_move)
	var _previous_move_direction: Vector2 = (_planned_move_tile_vector - _previous_tile_vector).normalized()
	var _result: Vector2 = _current_tile_vector + (_previous_move_direction * _distance)
	return  BattleController.get_tile(_result.x, _result.y)
