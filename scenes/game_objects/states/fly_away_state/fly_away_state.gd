extends StateWithMovement
class_name FlyAwayState

@export var fly_away_distance: int = 2
@export var state_after_flying: String

var next_turn_move_tile: Tile = null

func do_movement():
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
		next_turn_move_tile = null
		## Guard: only clear the move intent when we are permitted to update next_move.
		## This makes the code robust against any future config where is_able_to_do_move
		## is true but is_able_to_do_calculate_next_move is false — without this check,
		## the null assignment would silently clobber the player-visible arrow.
		## (StateWithMovement.do_state_action() provides a second layer of protection
		## via its save-and-restore, but explicit guards at the assignment site are
		## preferable to relying solely on the base class.)
		if _active_action_config.is_able_to_do_calculate_next_move:
			monster.next_move = null
		self.changed_state.emit(self, state_after_flying)
		return

	next_turn_move_tile = MovementUtils.move_away_from_tile(
		monster._tile,
		target._tile,
		fly_away_distance
	)
	## If we cannot actually move backwards do something else
	if not next_turn_move_tile:
		self.changed_state.emit(self, state_after_flying)
		return
	monster.next_move = next_turn_move_tile