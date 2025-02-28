extends Node

## Responsible for the monster behaviour. 
## It's responsible for where the monster is going to move
## and which tiles the monster is going to attack
class_name StateMachine

# TODO: The state should be responsible for sendind the squares that are being attacked

@export var initial_state: State

var states: Dictionary = {}
var current_state: State = null

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.changed_state.connect(_on_state_change)
	if initial_state:
		initial_state.enter_state()
		current_state = initial_state
			
func do_state_action():
	if current_state:
		current_state.do_state_action()


func _on_state_change(state: State, new_state_name: String):
	if state != current_state:
		return

	var new_state: State = states.get(new_state_name.to_lower()) 
	if !new_state:
		return
		
	if current_state:
		current_state.exit_state()
		
	new_state.enter_state()
	current_state = new_state
