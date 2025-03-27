extends Resource
class_name Progress

var current_health: int
var current_world_node_id: String 

func _init() -> void:
	current_health = 100
	current_world_node_id = str("village_node_id")
