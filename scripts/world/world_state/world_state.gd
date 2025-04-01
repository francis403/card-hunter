extends Node

## A loadable worldState
class_name WorldState

var _world_state: Dictionary = {}

func to_dictionary() -> Dictionary:
	return _world_state

## TODO
func convert_node_to_world_state(root_node: WorldNode):
	_world_state.clear()
	_append_to_state(_world_state, root_node)
		
func _append_to_state(state: Dictionary, node: WorldNode):
	state[node.world_node_id] = node.convert_node_to_dictionary()
	for child in node.connections:
		_append_to_state(
			state[node.world_node_id][WorldNode.CONNECTIONS_DICTIONARY_FIELD],
			child
		)


func convert_world_state_to_node() -> WorldNode:	
	var result: WorldNode = _get_node_from_state(
		_world_state,
		Constants.VILLAGE_NODE_ID
	)
	
	return result

func _get_node_from_state(state: Dictionary, id: String) -> WorldNode:
	var result: WorldNode = WorldNode.new()
	result.load_node_from_dictionary(state[id])
	for connection_id in state[id][WorldNode.CONNECTIONS_DICTIONARY_FIELD].keys():
		result.connections.append(
			_get_node_from_state(
				state[id][WorldNode.CONNECTIONS_DICTIONARY_FIELD],
				connection_id
			)
		)
	## TODO: need to do the monsters
	
	return result
	
