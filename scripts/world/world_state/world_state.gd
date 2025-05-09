extends Node
## A loadable worldState
class_name WorldState

const WORLD_DICTIONARY_FIELD: String = "world"
const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/monster_hunt_world_node/monster_hunt_world_node.tscn")

## Represents the world state in a dictionary. 
## This is what is saved/loaded to file
var _world_state: Dictionary = {
	"world": {}
}

func to_dictionary() -> Dictionary:
	return _world_state

## TODO: we're completely clearing everything when we want to save, this cannot be ideal
func convert_node_to_world_state(root_node: GenericWorldNode):
	_world_state[WORLD_DICTIONARY_FIELD].clear()
	_append_to_state(_world_state[WORLD_DICTIONARY_FIELD], root_node)
		
func _append_to_state(state: Dictionary, node: GenericWorldNode):
	state[node.world_node_id] = node.convert_node_to_dictionary()
	for child in node.connections:
		_append_to_state(
			state[node.world_node_id][GenericWorldNode.CONNECTIONS_DICTIONARY_FIELD],
			child
		)

## TODO: need to find a way to convert from generic node to the specific world node
func convert_world_state_to_node() -> GenericWorldNode:
	var result: GenericWorldNode = _get_node_from_state(
		_world_state[WORLD_DICTIONARY_FIELD],
		Constants.VILLAGE_NODE_ID
	)
	
	return result

func _get_node_from_state(state: Dictionary, id: String) -> GenericWorldNode:
	#var result: GenericWorldNode = WORLD_NODE_SCENE.instantiate()
	var world_node_scene_path: String = state[id][GenericWorldNode.NODE_SCENE_PATH_DICTIONARY_FIELD]
	var result = load(world_node_scene_path).instantiate().duplicate()
	result.load_node_from_dictionary(state[id])
	for connection_id in state[id][GenericWorldNode.CONNECTIONS_DICTIONARY_FIELD].keys():
		result.connections.append(
			_get_node_from_state(
				state[id][GenericWorldNode.CONNECTIONS_DICTIONARY_FIELD],
				connection_id
			)
		)
	return result
	
