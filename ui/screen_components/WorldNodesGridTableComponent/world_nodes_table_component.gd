extends MarginContainer
class_name WorldNodesTableComponent

const CONSTANT_VALUE_FOR_WORLD_NODES_GENERATED: int = 3
const RADIUS: int = 30

@export_category("World Definition")
@export var x_table_size: int = 10
@export var y_table_size: int = 10
@export var world_nodes_container: Control

@export_category("World Generation Configuration")
@export var world_generator_config: WorldGeneratorConfig
@export var use_random_seed: bool = true
@export var constant_number_of_nodes_to_add: int = 0
@export var world_generation_seed: int = 0
@export var _max_depth_world_generation: int = 3

@export_category("World UI")
@export var seperation: int = 75

@export_category("Scene definitions")
@export var village_node_scene: PackedScene 

@export_category("Debug Settings")
@export var _generate_in_test_container: bool = false

@onready var table_center_point: Marker2D = %TableCenterPoint
@onready var world_nodes_container_test: Control = %WorldNodesContainerTest
@onready var table_helper: TableHelper = $TableHelper

## Number of nodes to be generated. Calculated at runtime
var _number_of_nodes_to_generate: int

## Count total number of nodes generated
var _total_number_of_nodes_generated: int = 0

## Number of nodes to generate for the village
var _number_of_village_children: int = 3

## Gives info of the furthest node from the root
var _further_distance_generated: int = 0

## Provides a quick access to all nodes by distance
var _nodes_by_distance_dictionary: Dictionary = {
	## distance: Array[GenericWorldNode]
}

## Hold the _village_node reference
var _village_node: GenericWorldNode

## Hold the reference to the center point of the table
var _table_center_point: Vector2

## Keep a reference to all world nodes
## Used to save world state
var _world_nodes: Array[GenericWorldNode] = []

func _init() -> void:
	if File.progress:
		_village_node = File.progress.village_node

func _ready() -> void:
	BattlemapSignals.expand_world.connect(expand_world)
	if not use_random_seed:
		seed(world_generation_seed)
	if not village_node_scene:
		push_error("Missing village node scene! Not able to generate world.")
		return
	if not world_generator_config:
		push_error("Missing world config! Not able to generate world.")
		return
	_initialize_fields()
	if _generate_in_test_container:
		_generate_world()

func _initialize_fields():
	_table_center_point = Vector2(x_table_size/2, y_table_size/2)
	self.world_generator_config.initialize_config()
	self._max_depth_world_generation = world_generator_config.max_distance_to_village
	self._number_of_village_children = world_generator_config.number_of_village_children_node
	if not self.world_nodes_container:
		world_nodes_container = world_nodes_container_test
	table_helper.init_table_helper(
		_table_center_point,
		_max_depth_world_generation,
		seperation
	)

func instantiate_world():
	if not _is_world_saved():
		_generate_world()
	else:
		_load_world()

func _generate_world():
	_number_of_nodes_to_generate = _calculate_total_number_of_nodes()
	_village_node = _place_village()
	_generate_village_children(_village_node)
	table_helper.block_adjancent_table_positions(_village_node.table_position)
	PlayerController.current_world_node = _village_node
	_generate_world_nodes(
		PlayerController.current_world_node,
		_number_of_nodes_to_generate
	)
	_village_node.reveal_connected_nodes()
	_save_world_state()

## TODO(FA): improve this
func expand_world():
	## TODO: calculate the total number of nodes to add based on the depth
	## block all positions at depth  2
	table_helper._show_available_pos()
	#table_helper._show_blocked_pos()
	var _number_of_nodes_to_add: int = 3
	var _current_number_of_nodes_added: int = 0
	for i in randi_range(0, _number_of_nodes_to_add):
		## TODO: figure out a smart way to continously expand the world organically
		var random_table_position: Vector2 = table_helper.get_random_position(
			3,
			4
		)
		if random_table_position < Vector2(0, 0):
			print("DEBUG: Error expanding world!")
			continue
		_generate_node_in_table(random_table_position, _village_node.table_position)


func get_random_world_boss_scene() -> PackedScene:
	return world_generator_config.generate_random_boss_monster_scene()

## TODO: improve this
## Village node + minimums 
func _calculate_total_number_of_nodes() -> int:
	var result: int = 1
	for _node in world_generator_config.available_world_nodes:
		if _node.minimum_distance_to_root <= _max_depth_world_generation:
			result += _node.min_occurrences
	return result

func _place_village() -> GenericWorldNode:
	_village_node = village_node_scene.instantiate()
	_village_node.world_node_id = Constants.VILLAGE_NODE_ID
	_village_node.is_revealed = true
	_village_node.is_reachable = true
	_village_node.global_position = table_center_point.global_position
	_village_node.table_position = _table_center_point
	_add_node_to_table(_village_node)
	return _village_node

func _generate_village_children(
	_village_world_node: GenericWorldNode
):
	var _village_table_position: Vector2 = _village_world_node.table_position
	## Add positions
	var _picked_adjacent_positions: Array[Vector2] = [
		_village_table_position + Vector2(0, -1),
		_village_table_position + Vector2(1, 1),
		_village_table_position + Vector2(-1, 1)
	]
	for _child_position: Vector2 in _picked_adjacent_positions:
		_generate_node_in_table(_child_position, _village_world_node.table_position)

## Generate a number of children for a specific node
## -1 for random
func _generate_node_children(
	_center_node: GenericWorldNode,
	_number_of_children: int = -1
):
	var _picked_adjacent_positions: Array[Vector2] = []

func _generate_world_nodes(
	_center_node: GenericWorldNode,
	_nbr_of_nodes_to_generate: int = _number_of_nodes_to_generate
):
	var _center_position: Vector2 = _center_node.table_position
	var _minimum_distance: int = 2
	## To avoid an infinite loop
	var _number_of_loops: int = 0
	var _max_loops: int = 50
	while _total_number_of_nodes_generated < _nbr_of_nodes_to_generate and _number_of_loops < _max_loops:
		## TODO(FA): We need to only generate the position if it's available
		var random_table_position: Vector2 = table_helper.get_random_position(
			_minimum_distance,
			_max_depth_world_generation
		)
		_minimum_distance = max(world_generator_config.get_min_node_distance(), _minimum_distance)
		_number_of_loops += 1
		if random_table_position < Vector2(0, 0):
			print("Error with: random_table_position!")
			continue
		_generate_node_in_table(random_table_position, _center_position)
	print("DEBUG: generation World generated in: ", _number_of_loops, " loops!")

func _generate_node_in_table(
	_node_position: Vector2,
	_center_position: Vector2
):
	var _distance_to_center: int = table_helper.distance_between_two_points(_center_position, _node_position)
	var generated_node: GenericWorldNode = world_generator_config.generate_node(_distance_to_center)
	if not generated_node:
		push_warning(_generate_node_in_table, "WARNING: _node_position: ", _node_position, " failed to be generated!")
		return
	var base_node: GenericWorldNode = table_helper.get_origin_node(_node_position, _distance_to_center)
	generated_node.table_position = _node_position
	#generated_node.global_position = _calculate_node_position(generated_node.table_position)
	generated_node.global_position = table_helper.calculate_positions_in_radius(
		base_node,
		generated_node.table_position
	)
	generated_node.world_node_id = str(_total_number_of_nodes_generated)
	base_node.connections.append(generated_node)
	#generated_node.connections.append(base_node)
	_add_node_to_table(generated_node, _distance_to_center)
	_draw_line_between_nodes(base_node, generated_node)

func _add_node_to_table(_node: GenericWorldNode, _distance_to_root: int = 0):
	world_nodes_container.add_child(_node)
	table_helper.store_adjacent_table_positions(_node, _distance_to_root)
	_total_number_of_nodes_generated += 1
	_world_nodes.append(_node)
	if _nodes_by_distance_dictionary.has(_distance_to_root):
		_nodes_by_distance_dictionary[_distance_to_root].append(_node)
	else:
		_nodes_by_distance_dictionary[_distance_to_root] = [_node]
	_further_distance_generated = max(_further_distance_generated, _distance_to_root)

func _draw_line_between_nodes(base_node: GenericWorldNode, other_node: GenericWorldNode):
	var line = Line2D.new()
	var angle: float = base_node.global_position.angle_to_point(other_node.global_position)
	var offset: Vector2 = Vector2(-1 * RADIUS, 0)
	
	line.add_point(base_node.global_position - offset.rotated(angle))
	line.add_point(other_node.global_position + offset.rotated(angle))
	line.default_color = Color.BLACK
	line.width = 2
	
	world_nodes_container.add_child(line)
	
func _is_world_saved() -> bool:
	return _village_node != null
	
func _save_world_state():
	print(_save_world_state)
	File.progress.village_node = _village_node
	File.progress.world_state.update_nodes_in_world_state(_world_nodes)

func _load_world():
	_load_village()

func _load_village():
	_village_node = File.progress.village_node
	_initiate_world()
	
func _initiate_world():
	var _nodes_to_load: Array= File.progress.world_state.get_world_nodes()
	for _node: GenericWorldNode in _nodes_to_load:
		var _distance: int = table_helper.distance_between_two_points(_node.table_position, _village_node.table_position)
		_add_node_to_table(_node, _distance)
		for _con in _node.connections:
			_draw_line_between_nodes(_node, _con)
