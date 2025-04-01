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
	current_world_node_id = str("village_node_id")
	world_state = WorldState.new()
