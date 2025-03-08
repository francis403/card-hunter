extends State
class_name StateWithMovement

var target: PlayerPiece
var monster: MonsterPiece
var monster_sprite: Sprite2D

func enter_state():
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	
func do_state_action():
	BattlemapSignals.deal_damage_to_attacked_squares.emit(
		monster._strength
	)
	self.do_movement()
	
func do_movement():
	pass
