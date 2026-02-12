extends PanelContainer
class_name CardModuleDisplayer

signal module_clicked(_module: CardModule)
signal graph_module_closed(_module: BaseCardModuleGraphNode)

const NODE_SPACING_X := 250
const NODE_SPACING_Y := 120

@export var card_resource: CardResourceV2

@export_group("Module Configuration")
@export var enable_module_deletion: bool = false:
	set(value):
		enable_module_deletion = value
		toggle_module_deletion(value)
## Can nodes add new connections between themselves
@export var enable_module_connection: bool = false:
	set(value):
		enable_module_connection = value
		_update_connection_mode()

@export_group("Scene configurations")
@export var start_graph_node_scene: PackedScene
@export var effect_graph_node_scene: PackedScene
@export var end_graph_node_scene: PackedScene

@onready var graph_edit: GraphEdit = %GraphEdit

var _head_module_displayed: CardModule
## Maps graph node name -> CardModule in the shadow tree
var _node_module_map: Dictionary = {}

func _ready() -> void:
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	_clear_graph()
	populate_from_card_resource(card_resource)

func populate_from_card_resource(_card_resource: CardResourceV2) -> void:
	if not _card_resource:
		return
	_clear_graph()
	# Ensure module tree is built (may not be if this is a fresh resource instance)
	if _card_resource.use_new_card_module_system and _card_resource.start_card_module.next_modules.is_empty():
		_card_resource._generate_card_modules_tree()
	if not _card_resource.start_card_module or _card_resource.start_card_module.next_modules.is_empty():
		_add_modules_flat(_card_resource.get_card_modules())
		return

	# Build shadow tree as a duplicate of the card's module tree
	var original_to_dup: Dictionary = {}
	_head_module_displayed = _deep_duplicate_module_tree(_card_resource.start_card_module, original_to_dup)

	var nodes_map: Dictionary = {}  # module.id -> node.name
	var levels := _get_modules_by_level(_head_module_displayed)
	var last_modules: Array[CardModule] = []

	# Create nodes with positions based on level
	for level_idx in levels.size():
		var level_modules: Array[CardModule] = levels[level_idx]
		for mod_idx in level_modules.size():
			var module: CardModule = level_modules[mod_idx]
			var node := _create_graph_node(module)
			node.position_offset = Vector2(
				level_idx * NODE_SPACING_X,
				mod_idx * NODE_SPACING_Y
			)
			graph_edit.add_child(node)
			nodes_map[module.id] = node.name
			_node_module_map[node.name] = module

			# Track modules without next_modules for end node connection
			if module.next_modules.is_empty():
				last_modules.append(module)

	# Create connections between modules
	_create_connections(_head_module_displayed, nodes_map)

	# Add end node and connect it
	_add_end_node(last_modules, nodes_map, levels.size())
	
func get_displayed_card_head() -> CardModule:
	return _head_module_displayed

func add_card_module(module: CardModule) -> void:
	var node: BaseCardModuleGraphNode = _create_graph_node(module)
	# Count existing non-end nodes for vertical positioning
	var module_count: int = 0
	for child in graph_edit.get_children():
		if child is GraphNode and not child is EndCardModuleGraphNode:
			module_count += 1

	node.position_offset = Vector2(0, module_count * NODE_SPACING_Y * 0.5)
	graph_edit.add_child(node)
	_node_module_map[node.name] = module


func get_card_modules() -> Array[CardModuleGraphNode]:
	var modules: Array[CardModuleGraphNode] = []
	for child in graph_edit.get_children():
		if child is CardModuleGraphNode:
			modules.append(child)
	return modules
	
func toggle_module_deletion(_are_modules_deletable: bool):
	if not graph_edit:
		return
	for _child in graph_edit.get_children():
		if _child is BaseCardModuleGraphNode:
			_child.toggle_close_button(_are_modules_deletable)

## TODO: this can probably be improved to be O(_number_card_modules)
func is_displayed_module_fully_connected() -> bool:
	if not _head_module_displayed or _node_module_map.is_empty():
		return false
	var connections := graph_edit.get_connection_list()

	# Build adjacency from connection list
	var outputs_from: Dictionary = {}  # node_name -> true
	var inputs_to: Dictionary = {}  # node_name -> true
	var has_end_connection := false
	for conn in connections:
		outputs_from[String(conn["from_node"])] = true
		inputs_to[String(conn["to_node"])] = true
		if conn["to_node"] == "end_node":
			has_end_connection = true

	if not has_end_connection:
		return false

	# Every non-start module must have an input, every non-leaf must have an output
	for node_name: String in _node_module_map:
		var module: CardModule = _node_module_map[node_name]
		if module == _head_module_displayed:
			# Start only needs an output
			if not outputs_from.has(node_name):
				return false
		else:
			# All other modules need an input
			if not inputs_to.has(node_name):
				return false

	return true

func _add_modules_flat(modules: Array[CardModule]) -> void:
	# Fallback for cards without start_card_module - display in a row
	for i in modules.size():
		var module := modules[i]
		var node: BaseCardModuleGraphNode = _create_graph_node(module)
		node.position_offset = Vector2(i * NODE_SPACING_X, 0)
		graph_edit.add_child(node)


func _get_modules_by_level(start_module: CardModule) -> Array[Array]:
	var levels: Array[Array] = []
	var current_layer: Array[CardModule] = [start_module]
	var visited: Dictionary = {}

	while not current_layer.is_empty():
		var typed_layer: Array[CardModule] = []
		typed_layer.assign(current_layer)
		levels.append(typed_layer)

		# Mark current layer as visited
		for module in current_layer:
			visited[module.id] = true

		# Get next layer
		var next_layer: Array[CardModule] = []
		for module in current_layer:
			for next_module in module.next_modules:
				if not visited.has(next_module.id) and not next_layer.has(next_module):
					next_layer.append(next_module)
		current_layer = next_layer

	return levels


func _create_graph_node(module: CardModule) -> BaseCardModuleGraphNode:
	var node: BaseCardModuleGraphNode
	match module.module_type:
		"START":
			node = start_graph_node_scene.instantiate()
			node.set_card_module(module)
		_:
			node = effect_graph_node_scene.instantiate()
			node.set_card_module(module)
			if module.module_type == "DECISION":
				node.configure_as_decision()
			else:
				node.configure_as_effect()
	node.name = _get_safe_node_name(module)
	node.toggle_close_button(enable_module_deletion)
	node.module_closed.connect(_on_module_closed)
	return node


func _create_connections(start_module: CardModule, nodes_map: Dictionary) -> void:
	var visited: Dictionary = {}
	var queue: Array[CardModule] = [start_module]

	while not queue.is_empty():
		var module: CardModule = queue.pop_front()
		if visited.has(module.id):
			continue
		visited[module.id] = true

		if not nodes_map.has(module.id):
			continue

		for next_module in module.next_modules:
			if nodes_map.has(next_module.id):
				graph_edit.connect_node(
					nodes_map[module.id], 0,
					nodes_map[next_module.id], 0
				)
			if not visited.has(next_module.id):
				queue.append(next_module)


func _add_end_node(last_modules: Array[CardModule], nodes_map: Dictionary, level_count: int) -> void:
	var end_node: EndCardModuleGraphNode = end_graph_node_scene.instantiate()
	end_node.name = "end_node"
	end_node.position_offset = Vector2((level_count + 0.5) * NODE_SPACING_X, 0)

	graph_edit.add_child(end_node)

	# Connect last modules to end node (use actual name in case of rename)
	var actual_end_name: String = end_node.name
	for module in last_modules:
		if nodes_map.has(module.id):
			graph_edit.connect_node(nodes_map[module.id], 0, actual_end_name, 0)


func _get_safe_node_name(module: CardModule) -> String:
	if module.id and not module.id.is_empty():
		return module.id
	return "module_%d" % module.get_instance_id()


func _clear_graph() -> void:
	if not graph_edit:
		return
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			graph_edit.remove_child(child)
			child.queue_free()
	_head_module_displayed = null
	_node_module_map.clear()


func _deep_duplicate_module_tree(source: CardModule, orig_to_dup: Dictionary) -> CardModule:
	if orig_to_dup.has(source):
		return orig_to_dup[source]
	var dup_module: CardModule = CardModule.new()
	dup_module.id = source.id
	dup_module.title = source.title
	dup_module.stamina_cost = source.stamina_cost
	dup_module.module_type = source.module_type
	dup_module.types = source.types.duplicate()
	dup_module.next_modules = []
	orig_to_dup[source] = dup_module
	for child in source.next_modules:
		dup_module.next_modules.append(_deep_duplicate_module_tree(child, orig_to_dup))
	return dup_module

func _update_connection_mode() -> void:
	if not graph_edit:
		return
	graph_edit.right_disconnects = enable_module_connection


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if not enable_module_connection:
		return
	var from: BaseCardModuleGraphNode = graph_edit.get_node(NodePath(from_node))
	var to: BaseCardModuleGraphNode = graph_edit.get_node(NodePath(to_node))
	if _get_output_connection_count(from_node) >= from.max_number_of_output_connections:
		return
	if _get_input_connection_count(to_node) >= to.max_number_of_input_connections:
		return
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	# Update shadow tree
	var from_module: CardModule = _node_module_map.get(String(from_node))
	var to_module: CardModule = _node_module_map.get(String(to_node))
	if from_module and to_module and not from_module.next_modules.has(to_module):
		from_module.next_modules.append(to_module)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if not enable_module_connection:
		return
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	# Update shadow tree
	var from_module: CardModule = _node_module_map.get(String(from_node))
	var to_module: CardModule = _node_module_map.get(String(to_node))
	if from_module and to_module:
		from_module.next_modules.erase(to_module)


func _get_output_connection_count(node_name: StringName) -> int:
	var count: int = 0
	for conn in graph_edit.get_connection_list():
		if conn["from_node"] == node_name:
			count += 1
	return count


func _get_input_connection_count(node_name: StringName) -> int:
	var count: int = 0
	for conn in graph_edit.get_connection_list():
		if conn["to_node"] == node_name:
			count += 1
	return count


func _on_module_closed(_module: BaseCardModuleGraphNode):
	# Remove from shadow tree
	var removed_module: CardModule = _node_module_map.get(_module.name)
	if removed_module:
		_node_module_map.erase(_module.name)
		# Remove from any parent's next_modules
		for tracked_module: CardModule in _node_module_map.values():
			tracked_module.next_modules.erase(removed_module)
	if graph_module_closed.has_connections():
		graph_module_closed.emit(self)
	else:
		_module.queue_free()
