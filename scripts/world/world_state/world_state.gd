extends Node
## A loadable worldState
class_name WorldState

const WORLD_DICTIONARY_FIELD: String = "world"
const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/world_node.tscn")

## Represents the world state in a dictionary. 
## This is what is saved/loaded to file
var _world_state: Dictionary = {
	"world": {}
}

func to_dictionary() -> Dictionary:
	return _world_state

## TODO: we're completely clearing everything when we want to save, this cannot be ideal
func convert_node_to_world_state(root_node: WorldNode):
	_world_state[WORLD_DICTIONARY_FIELD].clear()
	_append_to_state(_world_state[WORLD_DICTIONARY_FIELD], root_node)
		
func _append_to_state(state: Dictionary, node: WorldNode):
	state[node.world_node_id] = node.convert_node_to_dictionary()
	for child in node.connections:
		_append_to_state(
			state[node.world_node_id][WorldNode.CONNECTIONS_DICTIONARY_FIELD],
			child
		)

func convert_world_state_to_node() -> WorldNode:	
	var result: WorldNode = _get_node_from_state(
		_world_state[WORLD_DICTIONARY_FIELD],
		Constants.VILLAGE_NODE_ID
	)
	
	return result

##TODO: add monster reading
func _get_node_from_state(state: Dictionary, id: String) -> WorldNode:
	var result: WorldNode = WORLD_NODE_SCENE.instantiate()
	result.load_node_from_dictionary(state[id])
	for connection_id in state[id][WorldNode.CONNECTIONS_DICTIONARY_FIELD].keys():
		result.connections.append(
			_get_node_from_state(
				state[id][WorldNode.CONNECTIONS_DICTIONARY_FIELD],
				connection_id
			)
		)
	return result
	
