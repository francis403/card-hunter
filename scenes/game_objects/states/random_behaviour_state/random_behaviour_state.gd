extends State
class_name RandomBehaviourState


## Array of possible states with their weights
@export var weighted_states: Array[WeightedStateOption] = []

func after_enter_state(
	_state_action_config: StateActionConfig = StateActionConfig.new()
):
	super.enter_state(_state_action_config)
	_select_random_state()

func _select_random_state():
	if weighted_states.is_empty():
		push_warning("RandomBehaviourState has no weighted states configured")
		return

	# Calculate total weight
	var total_weight: float = 0.0
	for weighted_state in weighted_states:
		if weighted_state.weight > 0:
			total_weight += weighted_state.weight

	if total_weight <= 0:
		push_warning("RandomBehaviourState has no positive weights")
		return

	# Select a random state based on weights
	var random_value: float = randf() * total_weight
	var accumulated_weight: float = 0.0

	for weighted_state in weighted_states:
		if weighted_state.weight <= 0:
			continue
		accumulated_weight += weighted_state.weight
		if random_value <= accumulated_weight:
			self.changed_state.emit(self, weighted_state.state_name)
			return
