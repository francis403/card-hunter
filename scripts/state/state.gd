extends Node
class_name State

const MOVE_ICON = preload("res://assets/images/icons/monster_icons/behaviour_icons/move_icon.png")

@export var state_icon: Texture2D = MOVE_ICON

var number_of_active_turns: int = 0

## NOTE: each individual state will have to turn it on by default
var player_hit_during_turn: bool = false

signal changed_state(state: State, new_state: String)

var target: PlayerPiece
var monster: GenericMonster

## Run when changing states. 
## NOTE: current_state in state_machine is still the old one
func enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	number_of_active_turns = 0
	## TODO: this values are all the same always, they should be in the state_machine
	target = BattleController.get_player()
	monster = get_parent().get_parent()
	monster.set_state_icon(state_icon)
	monster.next_move = null

## Run after entering state but with current_state in state_machine updated. 
func after_enter_state():
	pass

## Run every monster turn after the first
func do_state_action(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	number_of_active_turns += 1
	player_hit_during_turn = false

func exit_state():
	pass

func highlight_attack_action():
	pass
