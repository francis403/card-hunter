extends Node
class_name State

signal changed_state(state: State, new_state: State)

@export var movement_behaviour_node: MovementBehaviour

## Monster behaviour to do during this state
@export var monster_behaviour: MonsterBehaviourResource

func enter_state():
	pass
	
func exit_state():
	pass
	
func do_state_action():
	pass

func highlight_attack_action():
	pass

func do_preview_action() -> void:
	pass
