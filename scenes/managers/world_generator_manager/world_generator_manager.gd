extends Node2D

## handles the world generation
## TODO: don't generate the world if the world has been generated at some point
class_name WorldGeneratorManager

const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/world_node.tscn")
const BATTLE_ONE_CRAB_SCENE = preload("res://scenes/battle_scenes/battle_one_crab_scene.tscn/battle_one_crab_scene.tscn")


@export_category("World Generation Specification")
@export var seed: String = ""
@export var max_distance_to_village: int = 1
@export var maximum_number_of_child_nodes: int = 3

@export_category("World Generation UI")
@export var seperation: int = 100
@export var world_node_container: Container
@export var village_node_marker: Marker2D

## TODO: Need an object class to represent the World
var village_node: WorldNode

func _draw():
	_remove_preview()
	if not File.progress.village_node:
		_generate_world()
	else:
		_load_world()

func _remove_preview():
	if not world_node_container:
		return
	for node in world_node_container.get_children():
		node.queue_free()
		
func _generate_world():
	_generate_village()
	_generate_adjacent_nodes(village_node)
	_save_world_state()
	_draw_line_between_connecting_nodes(village_node)

func _draw_line_between_connecting_nodes(base_node: WorldNode):
	for node in base_node.connections:
		## TODO: need to improve the line mechanism
		draw_line(
			base_node.global_position, 
			node.global_position + Vector2(0, 30), 
			Color.BLACK
		)
	
func _generate_village():
	village_node = WORLD_NODE_SCENE.instantiate()
	village_node._world_node_type = WorldNode.WorldNodeTypeEnum.VILLAGE
	village_node.world_node_id = str("village_node_id")
	village_node.is_showing_player_sprite = true
	village_node.global_position = village_node_marker.global_position
	world_node_container.add_child(village_node)

func _generate_adjacent_nodes(base_node: WorldNode):
	var initial_generated_node_position: Vector2 = Vector2(
				base_node.global_position.x - (seperation),
				base_node.global_position.y - (seperation)
			)
	for i in range(0, maximum_number_of_child_nodes):
		var generated_node: WorldNode = WORLD_NODE_SCENE.instantiate()
		var generated_node_position: Vector2 =\
			initial_generated_node_position + Vector2(i * seperation, 0)
		generated_node.global_position = generated_node_position
		generated_node.world_node_id = str(i)
		generated_node.quest_scene = BATTLE_ONE_CRAB_SCENE
		base_node.connections.append(generated_node)
		world_node_container.add_child(generated_node)
	#self.queue_redraw()

func _load_world():
	print(_load_world)
	_load_village()
	_load_connected_nodes(village_node)
	_draw_line_between_connecting_nodes(village_node)
	BattlemapSignals.hide_player_in_other_node.emit(File.progress.current_world_node_id)

func _load_village():
	village_node = File.progress.village_node
	world_node_container.add_child(village_node)

func _load_connected_nodes(base_node: WorldNode):
	for node in base_node.connections:
		world_node_container.add_child(node)

## TODO: need to improve this
func _save_world_state():
	File.progress.village_node = village_node.duplicate()
	File.progress.village_node.world_node_id = village_node.world_node_id
	File.progress.village_node.connections.clear()
	for node in village_node.connections:
		var node_copy: WorldNode = node.duplicate()
		node_copy.world_node_id = node.world_node_id
		node_copy.is_revealed = node.is_revealed
		File.progress.village_node.connections.append(node_copy)
