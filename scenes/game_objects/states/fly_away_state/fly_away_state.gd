extends StateWithMovement
class_name FlyAwayState

@export var fly_away_distance: int = 2
@export var state_after_flying: String

var next_turn_move_tile: Tile = null

func do_movement():
	if next_turn_move_tile:
		BattleController.battlemap.place_piece_in_tile(monster, next_turn_move_tile)
		next_turn_move_tile = null
		monster.next_move = next_turn_move_tile
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
