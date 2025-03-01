extends MonsterPiece
class_name CrabMonster

#TODO: will need to create a basic enemy scene

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine


func play_monster_turn():
	super.play_monster_turn()
	state_machine.do_state_action()
	self.end_monster_turn()
	
	
func on_battle_start_signal():
	state_machine.do_state_action()
	
func get_sprite() -> Sprite2D:
	return sprite_2d

func highlight_attack_action() -> void:
	state_machine.current_state.highlight_attack_action()
