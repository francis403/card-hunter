extends State
class_name StateWithMovement

var target: PlayerPiece
var monster: GenericMonster

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	monster.set_state_icon(state_icon)
	
func do_state_action():
	BattlemapSignals.deal_damage_to_attacked_squares.emit(
		monster._strength
	)
	self.do_movement()
	
func do_movement():
	pass
