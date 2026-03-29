extends MarginContainer
class_name WorldNodesTableComponent

signal world_generated

## Radius used for line-drawing offset
const RADIUS: int = 30

## Scene used for the final converging boss node
const MONSTER_HUNT_NODE_SCENE = preload(
	"res://scenes/game_objects/world/world_node/monster_hunt_world_node/monster_hunt_world_node.tscn"
)

# ── Legacy exports kept so the existing .tscn inspector data is not lost ──
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

# ── Slay the Spire layout parameters ──
@export_category("Slay the Spire Layout")
## Vertical pixel distance between successive layers (rows)
@export var layer_vertical_spacing: int = 130
## Horizontal pixel distance between sibling nodes inside the same layer
@export var node_horizontal_spacing: int = 160
## Minimum number of "middle" layers (excludes the start and boss layers)
@export var min_middle_layers: int = 3
## Maximum number of "middle" layers (excludes the start and boss layers).
## The layered generator produces between (min_middle_layers + 2) and
## (max_middle_layers + 2) total layers. Keep this value in sync with
## RandomWorldGeneratorConfigManager._max_world_generation_depth.
@export var max_middle_layers: int = 5

@onready var table_center_point: Marker2D = %TableCenterPoint
@onready var world_nodes_container_test: Control = %WorldNodesContainerTest
@onready var table_helper: TableHelper = $TableHelper

# ── Internal state ──
var _total_number_of_nodes_generated: int = 0
var _number_of_village_children: int = 3
var _further_distance_generated: int = 0

## Nodes indexed by their layer index (== old "distance to root")
var _nodes_by_distance_dictionary: Dictionary = {}

var _village_node: GenericWorldNode
var _table_center_point: Vector2

## Ordered list of every node ever added (used for save state)
var _world_nodes: Array[GenericWorldNode] = []

var _current_world_generation_config: WorldGeneratorConfig
var _debug_enabled: bool = false

## Each element is an Array[GenericWorldNode] representing one row/layer.
## _layers[0]      = [village]
## _layers[1]      = [node, node, node]   (always 3 paths from village)
## _layers[2..N-2] = 1–3 random middle nodes
## _layers[N-1]    = [boss_node]
var _layers: Array = []

# ──────────────────────────────────────────────
#  Lifecycle
# ──────────────────────────────────────────────

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
		_generate_world(world_generator_config)

func _initialize_fields() -> void:
	_table_center_point = Vector2(x_table_size / 2, y_table_size / 2)
	self.world_generator_config.initialize_config()
	self._max_depth_world_generation = world_generator_config.max_distance_to_village
	self._number_of_village_children = world_generator_config.number_of_village_children_node
	if not self.world_nodes_container:
		world_nodes_container = world_nodes_container_test
	table_helper.init_table_helper(_table_center_point, seperation)

# ──────────────────────────────────────────────
#  Public API (unchanged signatures)
# ──────────────────────────────────────────────

func instantiate_world() -> void:
	if not _is_world_saved():
		_generate_world(world_generator_config)
	else:
		_load_world()

func generate_new_world(
	_new_world_generator_config: WorldGeneratorConfig,
	_enable_debug: bool = false
) -> void:
	print("Generating new world (Slay the Spire style)...")
	if _enable_debug:
		self._debug_enabled = true
	_clean_world()
	_new_world_generator_config.initialize_config()
	self._max_depth_world_generation = _new_world_generator_config.max_distance_to_village
	_generate_world(_new_world_generator_config)
	File.update_player_position(_village_node)
	File.progress.world_state.clear_and_update_world_state(_world_nodes)
	self.world_generated.emit()
	if _enable_debug:
		self._debug_enabled = false

func get_random_world_boss_scene() -> PackedScene:
	if _current_world_generation_config:
		return _current_world_generation_config.generate_random_boss_monster_scene()
	return world_generator_config.generate_random_boss_monster_scene()

# ──────────────────────────────────────────────
#  World generation entry-point
# ──────────────────────────────────────────────

func _generate_world(_world_gen_config: WorldGeneratorConfig) -> void:
	_current_world_generation_config = _world_gen_config.duplicate()
	_current_world_generation_config.initialize_config()
	_generate_layered_world()
	_village_node.reveal_connected_nodes()
	self._save_world_state()

# ──────────────────────────────────────────────
#  Slay the Spire – layered tree generation
# ──────────────────────────────────────────────

## Builds the full world as a converging trinary tree.
## Layout (Y increases downward in Godot):
##   Village  – bottom of the screen   (layer 0)
##   …middle layers…
##   Boss     – top of the screen      (layer N-1)
func _generate_layered_world() -> void:
	var center_pos: Vector2 = table_center_point.global_position

	# ── 1. Determine how many layers this run will have ──
	var num_middle: int  = randi_range(min_middle_layers, max_middle_layers)
	var total_layers: int = num_middle + 2          # village + middle… + boss

	var layer_counts: Array[int] = _build_layer_counts(num_middle)

	# ── 2. Compute Y positions: village at bottom, boss at top ──
	var total_height: float = (total_layers - 1) * layer_vertical_spacing
	var bottom_y: float     = center_pos.y + total_height / 2.0   # village Y

	# ── 3. Create nodes layer by layer ──
	_layers.clear()
	for layer_idx in range(total_layers):
		var count: int     = layer_counts[layer_idx]
		var layer_y: float = bottom_y - layer_idx * layer_vertical_spacing
		var layer_nodes: Array = []   # Array[GenericWorldNode]

		for node_idx in range(count):
			# Centre-align nodes within the layer
			var x_offset: float = (node_idx - (count - 1) / 2.0) * node_horizontal_spacing
			var screen_pos: Vector2 = Vector2(center_pos.x + x_offset, layer_y)

			var node: GenericWorldNode
			if layer_idx == 0:
				node = _create_village_node(screen_pos)
			elif layer_idx == total_layers - 1:
				node = _create_boss_node(screen_pos, layer_idx)
			else:
				node = _create_regular_node(screen_pos, layer_idx)

			if node == null:
				push_warning(
					"WorldNodesTableComponent: failed to create node at layer %d, slot %d"
					% [layer_idx, node_idx]
				)
				continue

			# table_position encodes (column_index, layer_index) for save/load
			node.table_position = Vector2(node_idx, layer_idx)
			layer_nodes.append(node)

		_layers.append(layer_nodes)

	# ── 4. Wire up connections between consecutive layers ──
	for layer_idx in range(total_layers - 1):
		_connect_adjacent_layers(_layers[layer_idx], _layers[layer_idx + 1])

	# ── 5. Draw the path lines ──
	_redraw_all_connection_lines()

	if _debug_enabled:
		print(
			"DEBUG: generated %d layers, %d total nodes"
			% [total_layers, _total_number_of_nodes_generated]
		)

# ──────────────────────────────────────────────
#  Layer-count helper
# ──────────────────────────────────────────────

## Returns an int array of node counts per layer.
## Layer 0 = 1 (village), layer 1 = 3 (forced), middle = 1–3, last = 1 (boss).
func _build_layer_counts(num_middle: int) -> Array[int]:
	var counts: Array[int] = []
	counts.append(1)   # village
	counts.append(3)   # first row always 3 paths
	for i in range(1, num_middle):
		counts.append(randi_range(1, 3))
	counts.append(1)   # boss
	return counts

# ──────────────────────────────────────────────
#  Node factories
# ──────────────────────────────────────────────

func _create_village_node(screen_pos: Vector2) -> GenericWorldNode:
	_village_node = village_node_scene.instantiate()
	_village_node.world_node_id = Constants.VILLAGE_NODE_ID
	_village_node.is_revealed   = true
	_village_node.is_reachable  = true
	_village_node.global_position = screen_pos
	_add_node_to_table(_village_node, 0)
	PlayerController.current_world_node = _village_node
	return _village_node

func _create_boss_node(screen_pos: Vector2, layer_idx: int) -> GenericWorldNode:
	var boss_node: MonsterHuntWorldNode = MONSTER_HUNT_NODE_SCENE.instantiate()
	boss_node._is_boss_node    = true
	boss_node.world_node_id    = "boss_node"
	boss_node.global_position  = screen_pos
	boss_node.is_revealed      = false
	boss_node.is_reachable     = false
	_add_node_to_table(boss_node, layer_idx)
	return boss_node

## Generates a regular world node using the WorldGeneratorConfig.
## Falls back to a plain MonsterHuntWorldNode if the config is exhausted.
func _create_regular_node(screen_pos: Vector2, layer_idx: int) -> GenericWorldNode:
	var node: GenericWorldNode = _current_world_generation_config.generate_node(layer_idx)
	if not node:
		# Config ran out of available node types – use a basic monster node
		node = MONSTER_HUNT_NODE_SCENE.instantiate()
		if _debug_enabled:
			print(
				"DEBUG: config exhausted at layer %d, falling back to MonsterHuntWorldNode"
				% layer_idx
			)
	node.global_position = screen_pos
	node.world_node_id   = str(_total_number_of_nodes_generated)
	_add_node_to_table(node, layer_idx)
	return node

# ──────────────────────────────────────────────
#  Connection algorithm (no crossing paths)
# ──────────────────────────────────────────────

## Connects parent_layer → child_layer with three passes:
##   1. Every parent gets at least one child  (left-to-right spread)
##   2. Every child gets at least one parent  (fill orphans)
##   3. Optional extra connections  (random, 40 % chance per candidate)
##
## The spread formula  j = floor(i * n / m)  guarantees order is preserved
## so connection lines never cross each other.
func _connect_adjacent_layers(parent_layer: Array, child_layer: Array) -> void:
	var m: int = parent_layer.size()
	var n: int = child_layer.size()

	# Pass 1 – give every parent at least one outgoing edge
	for i in range(m):
		var j: int = clamp(int(float(i) * float(n) / float(m)), 0, n - 1)
		if not parent_layer[i].connections.has(child_layer[j]):
			parent_layer[i].connections.append(child_layer[j])

	# Pass 2 – ensure no child is an orphan (no incoming edge)
	for j in range(n):
		var has_parent: bool = false
		for p in parent_layer:
			if p.connections.has(child_layer[j]):
				has_parent = true
				break
		if not has_parent:
			var i: int = clamp(int(float(j) * float(m) / float(n)), 0, m - 1)
			if not parent_layer[i].connections.has(child_layer[j]):
				parent_layer[i].connections.append(child_layer[j])

	# Pass 3 – add random extra connections for a richer graph (no crossing)
	for i in range(m):
		var j_base: int  = clamp(int(float(i) * float(n) / float(m)), 0, n - 1)
		# Only reach one slot to the right to avoid crossing
		var j_extra: int = j_base + 1
		if j_extra < n and randf() < 0.4:
			if not parent_layer[i].connections.has(child_layer[j_extra]):
				parent_layer[i].connections.append(child_layer[j_extra])

# ──────────────────────────────────────────────
#  Drawing
# ──────────────────────────────────────────────

## Iterates the full layers array and draws every connection line.
func _redraw_all_connection_lines() -> void:
	for layer_idx in range(_layers.size() - 1):
		for parent_node in _layers[layer_idx]:
			for child_node in parent_node.connections:
				_draw_line_between_nodes(parent_node, child_node)

func _draw_line_between_nodes(base_node: GenericWorldNode, other_node: GenericWorldNode) -> void:
	var line := Line2D.new()
	var angle: float   = base_node.global_position.angle_to_point(other_node.global_position)
	var offset: Vector2 = Vector2(-1 * RADIUS, 0)
	line.add_point(base_node.global_position  - offset.rotated(angle))
	line.add_point(other_node.global_position + offset.rotated(angle))
	line.default_color = Color.BLACK
	line.width = 2
	world_nodes_container.add_child(line)

# ──────────────────────────────────────────────
#  Node table bookkeeping
# ──────────────────────────────────────────────

func _add_node_to_table(_node: GenericWorldNode, _distance_to_root: int = 0) -> void:
	world_nodes_container.add_child(_node)
	_total_number_of_nodes_generated += 1
	_world_nodes.append(_node)
	if _nodes_by_distance_dictionary.has(_distance_to_root):
		_nodes_by_distance_dictionary[_distance_to_root].append(_node)
	else:
		_nodes_by_distance_dictionary[_distance_to_root] = [_node]
	_further_distance_generated = max(_further_distance_generated, _distance_to_root)

# ──────────────────────────────────────────────
#  Housekeeping
# ──────────────────────────────────────────────

func _clean_world() -> void:
	# Remove every child from the main container, then free it (Issue 6 fix)
	for _node in world_nodes_container.get_children():
		world_nodes_container.remove_child(_node)
		_node.queue_free()
	# Same two-step cleanup for the test container (Issue 6 fix)
	for _node in world_nodes_container_test.get_children():
		world_nodes_container_test.remove_child(_node)
		_node.queue_free()
	_world_nodes.clear()
	_nodes_by_distance_dictionary.clear()
	_layers.clear()
	table_helper.clean()
	_total_number_of_nodes_generated = 0
	_further_distance_generated = 0
	# Null the reference so _is_world_saved() correctly returns false (Issue 4 fix)
	_village_node = null

# ──────────────────────────────────────────────
#  Save / Load
# ──────────────────────────────────────────────

## A world is considered saved when we have a non-null village reference.
## Because _clean_world() now nulls _village_node, this check is always reliable.
func _is_world_saved() -> bool:
	return _village_node != null

func _save_world_state() -> void:
	File.progress.village_node = _village_node
	File.progress.world_state.update_nodes_in_world_state(_world_nodes)

func _load_world() -> void:
	_village_node = File.progress.village_node
	_initiate_world()

func _initiate_world() -> void:
	var _nodes_to_load: Array = File.progress.world_state.get_world_nodes()
	for _node: GenericWorldNode in _nodes_to_load:
		# table_position.y encodes the layer index in the layered system
		var _layer_idx: int = int(_node.table_position.y)
		_add_node_to_table(_node, _layer_idx)
		for _con in _node.connections:
			_draw_line_between_nodes(_node, _con)

	# Rebuild _layers from the loaded nodes so any post-load code that
	# depends on _layers operates on a valid, ordered array (Issue 3 fix)
	_rebuild_layers_from_nodes(_world_nodes)

## Reconstructs the _layers array from a flat list of loaded nodes.
## Uses table_position.y as the layer index and table_position.x for
## left-to-right column order within each layer.
func _rebuild_layers_from_nodes(nodes: Array[GenericWorldNode]) -> void:
	_layers.clear()
	if nodes.is_empty():
		return

	# Determine the highest layer index present
	var max_layer: int = 0
	for node in nodes:
		max_layer = max(max_layer, int(node.table_position.y))

	# Pre-allocate empty sub-arrays for every layer
	_layers.resize(max_layer + 1)
	for i in range(_layers.size()):
		_layers[i] = []

	# Bucket each node into its layer
	for node in nodes:
		var layer_idx: int = int(node.table_position.y)
		_layers[layer_idx].append(node)

	# Sort each layer by column index to preserve left-right order
	for layer in _layers:
		layer.sort_custom(
			func(a: GenericWorldNode, b: GenericWorldNode) -> bool:
				return a.table_position.x < b.table_position.x
		)