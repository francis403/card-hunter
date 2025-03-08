extends Node
class_name State

signal changed_state(state: State, new_state: String)

func enter_state():
	pass
	
func exit_state():
	pass
	
func do_state_action():
	pass

func highlight_attack_action():
	pass

func do_preview_action(recalculate_move: bool = false) -> void:
	pass
