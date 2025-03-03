extends State
class_name MoveSpeedToPlayerAndRadiusAttack

var target: PlayerPiece
var monster: MonsterPiece

var attack_behaviour: MonsterBehaviourController = null

@export var range: int = 1

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	attack_behaviour =\
		monster_behaviour.attack_behaviour.instantiate()
	self.add_child(attack_behaviour)
	
func exit_state():
	pass
	
func do_state_action():
	if not monster_behaviour:
		return
		
	if movement_behaviour_node:
		movement_behaviour_node.do_movement()
	
	var distance_to_player = BattleController.distance_between_tiles(
		monster.next_move if monster.next_move else monster._tile,
		target._tile
	)
	
	if distance_to_player > 1:
		BattlemapSignals.clear_attack_highlight_tiles.emit()
		return
	
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
