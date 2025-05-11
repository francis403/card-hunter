extends State
class_name StateWithMovement

var target: PlayerPiece
var monster: GenericMonster

## Conditions to change state
@export var state_change_conditions: Array[StateChangeCondtion]

func enter_state():
	super.enter_state()
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	monster.set_state_icon(state_icon)
	
func do_state_action():
	super.do_state_action()
	BattlemapSignals.deal_damage_to_attacked_squares.emit(
		monster._strength
	)
	self.do_movement()
	
## Match first state condition found
func check_and_apply_state_change_action() -> bool:
	for state_change_condition in state_change_conditions:
		var is_state_changed: bool = state_change_condition.change_state_if_condition_applies(monster, self)
		if is_state_changed:
			return true
	return false

func do_movement():
	pass
