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

## Every time we add a new node, we add the adjacent positions here
## We then remove the node position from here
var _available_world_table_positions: Dictionary = {
	## <distance> :  { <table_position> : <root_node> }
}

## Store all positions added to the table
var _blocked_table_positions: Dictionary = {}

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

func instantiate_world():
	if not _is_world_saved():
		_generate_world()
	else:
		_load_world()

func _generate_world():
	_number_of_nodes_to_generate = _calculate_total_number_of_nodes()
	_village_node = _place_village()
	_generate_village_children(_village_node)
	_block_adjancent_table_positions(_village_node.table_position)
	PlayerController.current_world_node = _village_node
	_generate_world_nodes(
		PlayerController.current_world_node
	)
	_village_node.reveal_connected_nodes()
	_save_world_state()

func expand_world():
	pass

## Village node + minimums 
func _calculate_total_number_of_nodes() -> int:
	var result: int = 1
	for _node in world_generator_config.available_world_nodes:
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
	_center_node: GenericWorldNode
):
	var _center_position: Vector2 = _center_node.table_position
	var _minimum_distance: int = 1
	## To avoid an infinite loop
	var _number_of_loops: int = 0
	var _max_loops: int = 1000
	while _total_number_of_nodes_generated < _number_of_nodes_to_generate and _number_of_loops < _max_loops:
		## TODO(FA): We need to only generate the position if it's available
		var random_table_position: Vector2 = _get_random_position(_minimum_distance)
		if random_table_position < Vector2(0, 0):
			_blocked_table_positions[random_table_position] = true
			_number_of_loops += 1
			continue
		_generate_node_in_table(random_table_position, _center_position)
		_number_of_loops += 1

## Returns a random position, 
## or (-1, -1) if none is available
func _get_random_position(
	_min_distance_to_root: int = 0,
	_max_distance_to_root: int = 101
) -> Vector2:
	var _result: Vector2 = Vector2.ZERO
	var _random_distance: int = clamp(
		_available_world_table_positions.keys().pick_random(),
		_min_distance_to_root,
		_max_distance_to_root
	)
	if not _available_world_table_positions.has(_random_distance):
		return Vector2(-1, -1)
	if _available_world_table_positions[_random_distance].is_empty():
		return Vector2(-1, -1)
	return _available_world_table_positions[_random_distance].keys().pick_random()

func _generate_node_in_table(
	_node_position: Vector2,
	_center_position: Vector2
):
	var _distance_to_center: int = _distance_between_two_points(_center_position, _node_position)
	## TODO: we should check if the distance is okay
	var generated_node: GenericWorldNode = world_generator_config.generate_node(_distance_to_center)
	if not generated_node:
		push_warning(_generate_node_in_table, "WARNING: _node_position: ", _node_position, " failed to be generated!")
		return
	## TODO(FA): this might be not the correct distance
	var base_node: GenericWorldNode = _available_world_table_positions[_distance_to_center][_node_position]
	generated_node.table_position = _node_position
	#generated_node.global_position = _calculate_node_position(generated_node.table_position)
	generated_node.global_position = calculate_positions_in_radius(
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
	_store_adjacent_table_positions(_node, _distance_to_root)
	_total_number_of_nodes_generated += 1
	_world_nodes.append(_node)
	if _nodes_by_distance_dictionary.has(_distance_to_root):
		_nodes_by_distance_dictionary[_distance_to_root].append(_node)
	else:
		_nodes_by_distance_dictionary[_distance_to_root] = [_node]
	_further_distance_generated = max(_further_distance_generated, _distance_to_root)

func _store_adjacent_table_positions(
	_node: GenericWorldNode,
	_node_distance: int
):
	var center_position = _node.table_position
	_blocked_table_positions[center_position] = true
	var node_distance_to_center: int = _distance_between_two_points(_table_center_point, center_position)
	var radius: int = 1
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _table_position: Vector2 = Vector2(
				center_position.x + radius_x,
				center_position.y + radius_y
			)
			var _distance_to_root: int = _distance_between_two_points(
				_table_position,
				_table_center_point
			)
			if not _available_world_table_positions.has(_distance_to_root):
				_available_world_table_positions[_distance_to_root] = {}
			elif _available_world_table_positions[_distance_to_root].has(_table_position):
				continue
			if _blocked_table_positions.has(_table_position):
				_available_world_table_positions[_distance_to_root].erase(_table_position)
				continue
			# Only store positions that are same distance or farther from center (opposite direction)
			if _distance_to_root >= node_distance_to_center and _distance_to_root <= _max_depth_world_generation:
				_available_world_table_positions[_distance_to_root][_table_position] = _node
	_available_world_table_positions[_node_distance].erase(center_position)

func _block_adjancent_table_positions(
	_node_table_pos: Vector2
):
	var radius: int = 1
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _table_position: Vector2 = Vector2(
				_node_table_pos.x + radius_x,
				_node_table_pos.y + radius_y
			)
			var _distance: int = _distance_between_two_points(_table_center_point, _table_position)
			_blocked_table_positions[_table_position] = true
			_available_world_table_positions[_distance].erase(_table_position)

func _draw_line_between_nodes(base_node: GenericWorldNode, other_node: GenericWorldNode):
	var line = Line2D.new()
	var angle: float = base_node.global_position.angle_to_point(other_node.global_position)
	var offset: Vector2 = Vector2(-1 * RADIUS, 0)
	
	line.add_point(base_node.global_position - offset.rotated(angle))
	line.add_point(other_node.global_position + offset.rotated(angle))
	line.default_color = Color.BLACK
	line.width = 2
	
	world_nodes_container.add_child(line)

func _calculate_node_position(
	_table_position: Vector2,
	_center_point: Vector2 = _table_center_point
) -> Vector2:
	var table_offset = _table_position - _table_center_point
	
	# Normalize diagonal distances to match orthogonal distances
	var distance = table_offset.length()
	if distance > 0:
		#var normalized_offset = table_offset.normalized() * seperation * distance
		var normalized_offset = table_offset.normalized() * seperation
		var screen_position = table_center_point.global_position + normalized_offset
		return screen_position
	
	return table_center_point.global_position

func calculate_positions_in_radius(
	center_node: GenericWorldNode,
	table_position: Vector2
) -> Vector2:
	var center_table_position: Vector2 = center_node.table_position
	var table_offset = table_position - center_table_position
	
	# Calculate angle from center to target position
	var angle: float = atan2(table_offset.y, table_offset.x)
	
	# Position at fixed radius using the angle
	var offset = Vector2(cos(angle), sin(angle)) * seperation
	var screen_position: Vector2 = center_node.global_position + offset
	
	return screen_position

func _distance_between_two_points(
	_point_a: Vector2,
	_point_b: Vector2
) -> int:
	var x1 = _point_a.x
	var x2 = _point_b.x
	var y1 = _point_a.y
	var y2 = _point_b.y
	return round(
		pow(
			pow((x2 - x1), 2) + pow((y2 - y1), 2),
			0.5
		)
	)
	
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
		var _distance: int = _distance_between_two_points(_node.table_position, _village_node.table_position)
		_add_node_to_table(_node, _distance)
		for _con in _node.connections:
			_draw_line_between_nodes(_node, _con)
