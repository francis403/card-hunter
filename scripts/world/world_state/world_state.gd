extends Node

## A loadable worldState
class_name WorldState

var _world_state: Dictionary = {}

func to_dictionary() -> Dictionary:
	return _world_state

## TODO
func convert_node_to_world_state(root_node: WorldNode):
	_world_state = {}
	_append_to_state(_world_state, root_node)
		
func _append_to_state(state: Dictionary, node: WorldNode):
	state[node.world_node_id] = node.convert_node_to_dictionary()
	for child in node.connections:
		_append_to_state(
			state[node.world_node_id][WorldNode.CONNECTIONS_DICTIONARY_FIELD],
			child
		)

## TODO
func convert_world_state_to_node() -> WorldNode:
	return null
