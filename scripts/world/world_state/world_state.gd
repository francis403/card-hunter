extends Node
## A loadable worldState
class_name WorldState

const WORLD_DICTIONARY_FIELD: String = "world"
const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/monster_hunt_world_node/monster_hunt_world_node.tscn")

## Represents the world state in a dictionary. 
## This is what is saved/loaded to file
var _world_state: Dictionary = {
	"world": {}
}

## Quick access of loaded nodes
## ID: <loaded_world_node>
var world_nodes_dict: Dictionary = {}

func load_world_state(
	_dict: Dictionary
):
	_world_state = _dict.duplicate()
	var _world_dict: Dictionary = _world_state[WORLD_DICTIONARY_FIELD]
	world_nodes_dict.clear()
	for _key in _world_dict.keys():
		var _node: GenericWorldNode = self.load_node_from_memory(_key)
		world_nodes_dict[_key] = _node
	_connect_world_nodes()
	
func update_nodes_in_world_state(_nodes: Array[GenericWorldNode]):
	for _node in _nodes:
		update_node_in_world_state(_node)

func update_node_in_world_state(_node: GenericWorldNode):
	world_nodes_dict[_node.world_node_id] = _node
	_world_state[WORLD_DICTIONARY_FIELD][_node.world_node_id] = _node.convert_node_to_dictionary()

func load_node_from_memory(
	_id: String
) -> GenericWorldNode:
	if not _world_state[WORLD_DICTIONARY_FIELD].has(_id):
		return null
	var _node_dict: Dictionary = _world_state[WORLD_DICTIONARY_FIELD][_id]
	var _node_scene_path: String = _node_dict[GenericWorldNode.NODE_SCENE_PATH_DICTIONARY_FIELD]
	var _result: GenericWorldNode = load(_node_scene_path).instantiate()
	_result.load_node_from_dictionary(_node_dict)
	return _result

func get_world_nodes() -> Array:
	return world_nodes_dict.values()

func get_world_node(_node_id: String) -> GenericWorldNode:
	if not world_nodes_dict.has(_node_id):
		return null
	return world_nodes_dict[_node_id]

func to_dictionary() -> Dictionary:
	return _world_state

func _connect_world_nodes():
	var _world_nodes_dict: Dictionary = _world_state[WORLD_DICTIONARY_FIELD]
	for _node_dict: Dictionary in _world_nodes_dict.values():
		var _node: GenericWorldNode = world_nodes_dict[_node_dict[GenericWorldNode.ID_DICTIONARY_FIELD]]
		for _con_id in _node_dict[GenericWorldNode.CONNECTIONS_DICTIONARY_FIELD].keys():
			_node.connections.append(world_nodes_dict[_con_id])
