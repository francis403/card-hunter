extends State

## State with the following order:
## 1. do_trigger_attacked_tiles()
## 2. do_movement -> place piece in monster.next_move tile
## 3. do_calculate_next_action() -> see if new behaviour change is required
## 4. do_calculate_next_move() -> calculate monster.next_move tile
## 5. do_action() -> do state main functionality
## 6. do_attack() -> optional
class_name StateWithMovement

var distance_to_player: int = 0
var _tiles_targeted_for_attack: Array[Tile] = []

## Holds the StateActionConfig that is active for the current enter_state /
## do_state_action invocation.  Subclass overrides of do_action() and
## do_attack() MUST read this instead of directly manipulating monster.next_move
## so that pull-card preview calls (is_able_to_do_calculate_next_move = false)
## are respected and the intended move display is never silently clobbered.
var _active_action_config: StateActionConfig = StateActionConfig.new()

@export_group("Basic Behaviour Configuration")
## TODO: Attack tiles to highlight during do_action
@export var attack_tiles_highlight: TileHighlightConfig = null

## TODO: Defines the monster movement behaviour.
## If more than one tile is returned pick a random one
## If null moves up to player at speed
@export var move_tiles_possibilities: TileHighlightConfig = null
## Conditions to change state
@export var state_change_conditions: Array[StateChangeCondtion]

@export_group("Special Attack Configurations")
## Should the attack tiles be calculated from the monster future position or corrent position
@export var use_monster_next_move_as_origin_tile: bool = true
## Effect to add to tiles and/or pieces
@export var on_hit_tile_effect_resource: TileEffectResource

func enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.enter_state()
	if not monster or not monster._tile:
		push_warning("Monster missconfiguration")
		return
	# Snapshot the config so do_action() overrides can inspect it.
	_active_action_config = _state_action_config
	if _state_action_config.is_able_to_do_calculate_next_move:
		monster.next_move = self.do_calculate_next_move()
	do_update_variables_after_movement()
	if _state_action_config.is_able_to_do_action:
		self.do_action()
	if _state_action_config.is_able_to_do_calculate_next_action:
		self.do_calculate_next_action()
	
func do_state_action(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.do_state_action()
	# Snapshot the config so do_action() / do_attack() overrides can inspect it.
	_active_action_config = _state_action_config
	## Trigger any atacked tiles by the monster's previous attack
	if _state_action_config.is_able_to_do_trigger_previous_attacked_tiles:
		self.do_trigger_attacked_tiles()
	## Move the monster
	if _state_action_config.is_able_to_do_move:
		self.do_movement()
	## Calculate the monster's next action
	var _new_action: bool = false
	if _state_action_config.is_able_to_do_calculate_next_action:
		_new_action = self.do_calculate_next_action()
	if _new_action:
		return
	if _state_action_config.is_able_to_do_calculate_next_move:
		monster.next_move = self.do_calculate_next_move(
			_state_action_config.should_keep_same_movement_logic
		)
	self.do_update_variables_after_movement()
	## Do whatever the monster wants to do there
	if _state_action_config.is_able_to_do_action:
		self.do_action()
	if _state_action_config.is_able_to_do_attack:
		self.do_attack()

## -- Override this functions to define the behaviour --
func do_update_variables_after_movement():
	distance_to_player = MovementUtils.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)

func do_trigger_attacked_tiles():
	if target and target._tile.is_tile_attacked:
		target.hit_player(
			monster._tile,
			monster._strength
		)
		self.player_hit_during_turn = true
	_add_tile_effect()

func do_movement():
	if not monster:
		return
	var next_turn_move_tile: Tile = monster.next_move
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
	
	
## Calculates the monster next move. 
## By default moves toward the target (player)
## If _should_keep_same_movement_logic is true:
## - The direction the monster previously moved should be kept
## - If no direction, then no movement
func do_calculate_next_move(
	_should_keep_same_movement_logic: bool = false
) -> Tile:
	if not target or not monster:
		return null
	if _should_keep_same_movement_logic:
		return _get_same_direction_monster_movement()
	if not move_tiles_possibilities:
		return _move_towards_player()
	else:
		## TODO: Think, does it make sense for the monster movement to be angled to the player?
		move_tiles_possibilities.origin_tile = monster._tile
		move_tiles_possibilities.target_tile = target._tile
		var _possible_moves: Array[Tile] = MovementUtils.get_tiles_for_config(
			monster._tile,
			move_tiles_possibilities
		)
		if _possible_moves.is_empty():
			return null
		return _possible_moves.pick_random()

func _move_towards_player() -> Tile:
	return MovementUtils.get_movement_tile(
		monster._tile,
		target._tile,
		monster._speed
	)
	
## Do any special actions.
## Runs every turn (including when enter_state)
func do_action():
	if not attack_tiles_highlight:
		return
	attack_tiles_highlight.origin_tile = monster._tile\
		if not monster.next_move or not self.use_monster_next_move_as_origin_tile\
		else monster.next_move
	attack_tiles_highlight.target_tile = target._tile
	BattleController.battlemap.clear_highlighted_tiles()
	_tiles_targeted_for_attack = BattleController.battlemap.highlight_attack_tiles(
		attack_tiles_highlight.origin_tile,
		attack_tiles_highlight
	)
	
## Highlight any attack tiles. Not required
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
	
	
func _add_tile_effect():
	if not self.on_hit_tile_effect_resource\
		 or not on_hit_tile_effect_resource.tile_effect_controller.can_instantiate() :
		return
	var tile_effect_controller: BaseTileEffectController =\
			on_hit_tile_effect_resource.tile_effect_controller.instantiate()
	tile_effect_controller.tile_effect_resource = self.on_hit_tile_effect_resource
	for _tile: Tile in _tiles_targeted_for_attack:
		_tile.add_tile_effect_v2(
			tile_effect_controller
		)