extends Resource
class_name Progress

var current_health: int
var current_world_node_id: String 

## Already loaded world
var village_node: WorldNode

## Dictionary representation of the world
var world_state: WorldState

func _init() -> void:
	current_health = 100
	current_world_node_id = Constants.VILLAGE_NODE_ID
	world_state = WorldState.new()

func update_player_position(current_world_node: WorldNode):
	PlayerController.current_world_node.hide_player()
	File.progress.current_world_node_id = current_world_node.world_node_id
	PlayerController.current_world_node = current_world_node
	PlayerController.current_world_node.show_player()
