extends Node

## handles the world generation
## TODO: don't generate the world if the world has been generated at some point
class_name WorldGeneratorManager

const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/world_node.tscn")

@onready var world_nodes: MarginContainer = $"../WorldNodes"


@export_category("World Generation Specification")
@export var seed: String = ""
@export var world_hight: int = 2
@export var maximum_number_of_child_nodes: int = 3

@export_category("World Generation UI")
@export var sepeartion_between_leefs: int = 15
@export var world_node_container: Container
@export var village_node_marker: Marker2D


## Village node should contain all the info required to get all the other nodes
## TODO: need a good way to identify which node the player is at any point
var village_node: WorldNode

func _ready() -> void:
	_remove_preview()
	_generate_world()
	
	
func _remove_preview():
	for node in world_nodes.get_children():
		node.queue_free()
		
func _generate_world():
	_generate_village()
	
func _generate_village():
	village_node = WORLD_NODE_SCENE.instantiate()
	village_node._world_node_type = WorldNode.WorldNodeTypeEnum.VILLAGE
	village_node.global_position = village_node_marker.global_position
	world_node_container.add_child(village_node)
