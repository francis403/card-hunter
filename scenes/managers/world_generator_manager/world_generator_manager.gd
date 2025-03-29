extends Node2D

## handles the world generation
## TODO: don't generate the world if the world has been generated at some point
class_name WorldGeneratorManager

const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/world_node.tscn")
const BATTLE_ONE_CRAB_SCENE = preload("res://scenes/battle_scenes/battle_one_crab_scene.tscn/battle_one_crab_scene.tscn")
const RADIUS = 30

@export_category("World Generation Specification")
@export var seed: String = ""
@export var max_distance_to_village: int = 3
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
	_generate_adjacent_nodes(village_node, maximum_number_of_child_nodes, 1)
	#for node in village_node.connections:
		#_generate_adjacent_nodes(
			#node,
			#randi_range(0, maximum_number_of_child_nodes)
		#)
	_save_world_state()

func _draw_line_between_connecting_nodes(base_node: WorldNode):
	for node in base_node.connections:
		_draw_line_between_nodes(base_node, node)
	
func _draw_line_between_nodes(base_node: WorldNode, other_node: WorldNode):
	var angle: float = base_node.global_position.angle_to_point(other_node.global_position)
	var offset: Vector2 = Vector2(-1 * RADIUS, 0)
	draw_line(
			base_node.global_position, 
			other_node.global_position + offset.rotated(angle), 
			Color.BLACK
		)
	
func _generate_village():
	village_node = WORLD_NODE_SCENE.instantiate()
	village_node._world_node_type = WorldNode.WorldNodeTypeEnum.VILLAGE
	village_node.world_node_id = str("village_node_id")
	village_node.is_showing_player_sprite = true
	village_node.global_position = village_node_marker.global_position
	world_node_container.add_child(village_node)

func _generate_adjacent_nodes(
	base_node: WorldNode,
	number_of_children: int = self.maximum_number_of_child_nodes,
	current_build_depth: int = 0
):
	var initial_generated_node_position: Vector2 = Vector2(
				base_node.global_position.x - (seperation),
				base_node.global_position.y - (seperation)
			)
	for i in range(base_node.connections.size(), number_of_children):
		var generated_node: WorldNode = WORLD_NODE_SCENE.instantiate()
		var generated_node_position: Vector2 =\
			initial_generated_node_position + Vector2(i * seperation, 0)
		generated_node.global_position = get_node_iteration_position(base_node, i)
		generated_node.world_node_id = str(i)
		generated_node.quest_scene = BATTLE_ONE_CRAB_SCENE
		generated_node.connections.append(base_node)
		base_node.connections.append(generated_node)
		world_node_container.add_child(generated_node)
		_draw_line_between_nodes(base_node, generated_node)
		if current_build_depth <= max_distance_to_village:
			_generate_adjacent_nodes(
				generated_node,
				randi_range(0, maximum_number_of_child_nodes),
				current_build_depth + 1
			)

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

func get_random_node_position(center_node: WorldNode) -> Vector2:
	var angle = randf_range(0, TAU)
	var position_offset: Vector2 = Vector2(seperation, 0).rotated(angle)
	return center_node.global_position + position_offset
	
func get_node_iteration_position(center_node: WorldNode, iteration: int) -> Vector2:
	var partition: float =  (float(iteration + 1)/ maximum_number_of_child_nodes)
	var angle: float = partition * TAU
	var position_offset: Vector2 = Vector2(seperation, 0).rotated(angle)
	return center_node.global_position + position_offset

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
