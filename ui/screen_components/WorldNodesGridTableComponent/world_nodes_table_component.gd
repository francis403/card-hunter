extends MarginContainer
class_name WorldNodesTableComponent

const CONSTANT_VALUE_FOR_WORLD_NODES_GENERATED: int = 3
const RADIUS: int = 30

@export_category("World Definition")
@export var x_table_size: int = 10
@export var y_table_size: int = 10
@export  var world_nodes_container: Control

@export_category("World Generation Configuration")
@export var world_generator_config: WorldGeneratorConfig

@export_category("World UI")
@export var seperation: int = 75

@export_category("Scene definitions")
@export var village_node_scene: PackedScene 

@onready var table_center_point: Marker2D = %TableCenterPoint
@onready var world_nodes_container_test: Control = %WorldNodesContainerTest

var _number_of_nodes_to_generate: int = 1
## Count total number of nodes generated
var _total_number_of_nodes_generated: int = 0

var _max_depth_world_generation: int = 3

## Every time we add a new node, we add the adjacent positions here
## We then remove the node position from here
var _available_world_table_positions: Dictionary = {}

## Store all positions added to the table
var _added_world_table_positions: Dictionary = {}

## Hold the _village_node reference
var _village_node: GenericWorldNode

## Hold the reference to the center point of the table
var _table_center_point: Vector2


func _init() -> void:
	_village_node = File.progress.village_node

func _ready() -> void:
	if not village_node_scene:
		push_error("Missing village node scene! Not able to generate world.")
		return
	if not world_generator_config:
		push_error("Missing world config! Not able to generate world.")
		return
	_initialize_fields()
	#if not _is_world_saved:
	#generate_world()
	#else:
		#_load_world()

func _initialize_fields():
	_table_center_point = Vector2(x_table_size/2, y_table_size/2)
	self.world_generator_config.initialize_config()
	self._max_depth_world_generation = world_generator_config.max_distance_to_village
	if not self.world_nodes_container:
		world_nodes_container = world_nodes_container_test

func generate_world():
	_number_of_nodes_to_generate = _calculate_total_number_of_nodes()
	_village_node = _place_village()
	PlayerController.current_world_node = _village_node
	_generate_adjacent_nodes(
		PlayerController.current_world_node,
		3
	)
	_village_node.reveal_connected_nodes()
	_save_world_state()

func get_nodes() -> Array[Node]:
	return world_nodes_container.get_children()

## Village node + minimums 
func _calculate_total_number_of_nodes() -> int:
	var result: int = 1
	for _node in world_generator_config.available_world_nodes:
		result += _node.min_occurrences
	return result

func _place_village() -> GenericWorldNode:
	_village_node = village_node_scene.instantiate()
	_village_node.world_node_id = Constants.VILLAGE_NODE_ID
	_village_node.is_showing_player_sprite = true
	_village_node.is_revealed = true
	_village_node.is_reachable = true
	_village_node.global_position = table_center_point.global_position
	_village_node.table_position = _table_center_point
	_add_node_to_table(_village_node)
	return _village_node

func _generate_adjacent_nodes(
	_center_node: GenericWorldNode,
	_number_of_children: int = 2
):
	var _distance_to_center: int = 0
	var _center_position: Vector2 = _center_node.table_position
	while _total_number_of_nodes_generated <= _number_of_nodes_to_generate:
		var random_table_position: Vector2 = _get_adjacent_table_position(_center_position)
		if not random_table_position:
			return
		_distance_to_center = _distance_between_two_points(_center_position, random_table_position)
		var generated_node: GenericWorldNode = world_generator_config.generate_node(_distance_to_center)
		var base_node: GenericWorldNode = _available_world_table_positions[random_table_position]
		generated_node.table_position = random_table_position
		generated_node.global_position = _calculate_node_position(generated_node.table_position)
		generated_node.world_node_id = str(_total_number_of_nodes_generated)
		base_node.connections.append(generated_node)
		_add_node_to_table(generated_node)
		_draw_line_between_nodes(base_node, generated_node)

func _get_adjacent_table_position(_table_position: Vector2) -> Vector2:
	return _available_world_table_positions.keys().pick_random()

func _add_node_to_table(_node: GenericWorldNode):
	world_nodes_container.add_child(_node)
	_store_adjacent_table_positions(_node)
	_total_number_of_nodes_generated += 1

func _store_adjacent_table_positions(
	_node: GenericWorldNode
):
	var center_position = _node.table_position
	_added_world_table_positions[center_position] = true
	var radius: int = 1
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _table_position: Vector2 = Vector2(
				center_position.x + radius_x,
				center_position.y + radius_y
			)
			var _distance_to_center: int = _distance_between_two_points(_table_center_point, _table_position)
			if not _added_world_table_positions.has(_table_position) and _distance_to_center <= _max_depth_world_generation:
				_available_world_table_positions[_table_position] = _node
	_available_world_table_positions.erase(center_position)

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
	_table_position: Vector2
) -> Vector2:
	var table_offset = _table_position - _table_center_point
	
	# Normalize diagonal distances to match orthogonal distances
	var distance = table_offset.length()
	if distance > 0:
		var normalized_offset = table_offset.normalized() * seperation * distance
		var screen_position = table_center_point.global_position + normalized_offset
		return screen_position
	
	return table_center_point.global_position

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
	File.progress.world_state.convert_node_to_world_state(_village_node)

func _load_world():
	pass
