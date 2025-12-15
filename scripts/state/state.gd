extends Node
class_name State

const MOVE_ICON = preload("res://assets/images/icons/monster_icons/behaviour_icons/move_icon.png")

@export var state_icon: Texture2D = MOVE_ICON

var number_of_active_turns: int = 0

signal changed_state(state: State, new_state: String)

func enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	number_of_active_turns = 0

func do_state_action(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	number_of_active_turns += 1

func exit_state():
	pass

func highlight_attack_action():
	pass
