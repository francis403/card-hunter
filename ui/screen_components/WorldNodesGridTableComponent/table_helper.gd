extends Node
class_name TableHelper

var _table_center_point: Vector2
var _seperation: int
var _max_depth_world_generation: int

## Store all positions that can never have a node
var _blocked_table_positions: Dictionary = {}

## Every time we add a new node, we add the adjacent positions here
## We then remove the node position from here
var _available_world_table_positions: Dictionary = {
	## <distance> :  { <table_position> : <root_node> }
}

@export var _table_center_point_marker2d: Marker2D

func init_table_helper(
	table_center_point: Vector2,
	max_depth_world_generation: int,
	seperation: int
) -> void:
	_table_center_point = table_center_point
	_max_depth_world_generation = max_depth_world_generation
	_seperation = seperation

func _table_position_distance(
	_table_node_a: GenericWorldNode,
	_table_node_b: GenericWorldNode
) -> int:
	return distance_between_two_points(_table_node_a.table_position, _table_node_b.table_position)

func distance_between_two_points(
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

## Returns a random position, 
## or (-1, -1) if none is available
func get_random_position(
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

## Returns root of the node. Used for connecting between two nodes
func get_origin_node(
	_node_pos: Vector2,
	_distance: int = 0
) -> GenericWorldNode:
	return _available_world_table_positions[_distance][_node_pos]

func calculate_positions_in_radius(
	center_node: GenericWorldNode,
	table_position: Vector2
) -> Vector2:
	var center_table_position: Vector2 = center_node.table_position
	var table_offset = table_position - center_table_position
	
	# Calculate angle from center to target position
	var angle: float = atan2(table_offset.y, table_offset.x)
	
	# Position at fixed radius using the angle
	var offset = Vector2(cos(angle), sin(angle)) * _seperation
	var screen_position: Vector2 = center_node.global_position + offset
	
	return screen_position

func store_adjacent_table_positions(
	_node: GenericWorldNode,
	_node_distance: int
):
	var center_position = _node.table_position
	self.block_table_pos(center_position)
	var node_distance_to_center: int = self.distance_between_two_points(_table_center_point, center_position)
	var radius: int = 1
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _table_position: Vector2 = Vector2(
				center_position.x + radius_x,
				center_position.y + radius_y
			)
			var _distance_to_root: int = self.distance_between_two_points(
				_table_position,
				_table_center_point
			)
			if not _available_world_table_positions.has(_distance_to_root):
				_available_world_table_positions[_distance_to_root] = {}
			elif _available_world_table_positions[_distance_to_root].has(_table_position):
				continue
			if self.is_position_blocked(_table_position):
				_available_world_table_positions[_distance_to_root].erase(_table_position)
				continue
			# Only store positions that are same distance or farther from center (opposite direction)
			if _distance_to_root >= node_distance_to_center and _distance_to_root <= _max_depth_world_generation:
				_available_world_table_positions[_distance_to_root][_table_position] = _node
	_available_world_table_positions[_node_distance].erase(center_position)

func is_position_blocked(
	_table_pos: Vector2
) -> bool:
	return _blocked_table_positions.has(_table_pos) 

func block_table_pos(
	_table_pos: Vector2
) -> void:
	_blocked_table_positions[_table_pos] = true

func block_adjancent_table_positions(
	_node_table_pos: Vector2
):
	var radius: int = 1
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _table_position: Vector2 = Vector2(
				_node_table_pos.x + radius_x,
				_node_table_pos.y + radius_y
			)
			var _distance: int = self.distance_between_two_points(_table_center_point, _table_position)
			_blocked_table_positions[_table_position] = true
			_available_world_table_positions[_distance].erase(_table_position)
