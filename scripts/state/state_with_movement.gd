extends State
class_name StateWithMovement

var target: PlayerPiece
var monster: MonsterPiece
var monster_sprite: Sprite2D

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	
func do_movement():
	pass
