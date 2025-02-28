extends State
class_name BasicCloseRangeAttackState

var target: PlayerPiece
var monster: MonsterPiece

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	
func exit_state():
	pass
	
func do_state_action():
	print(do_state_action)
	if not monster_behaviour:
		return
	if movement_behaviour_node:
		movement_behaviour_node.do_movement()
	if monster_behaviour.attack_behaviour:
		# TODO: should this be just like the movement behaviour??
		var attack_behaviour: MonsterBehaviourController =\
			monster_behaviour.attack_behaviour.instantiate()
		attack_behaviour.play_monster_behaviour(
			monster_behaviour
		)
