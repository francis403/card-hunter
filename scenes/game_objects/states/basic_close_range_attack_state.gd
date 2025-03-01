extends State
class_name BasicCloseRangeAttackState

var target: PlayerPiece
var monster: MonsterPiece

var attack_behaviour: MonsterBehaviourController = null

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	attack_behaviour =\
		monster_behaviour.attack_behaviour.instantiate()
	self.add_child(attack_behaviour)
	
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
		attack_behaviour.play_monster_behaviour(
			monster_behaviour
		)

func do_preview_action():
	if not monster_behaviour:
		return
	attack_behaviour.preview_monster_behaviour(
		monster_behaviour
	)
