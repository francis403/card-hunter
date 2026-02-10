extends PanelContainer
class_name CardModuleDisplayer

const NODE_SPACING_X := 250
const NODE_SPACING_Y := 120

@export var card_resource: CardResourceV2

@export_group("Scene configurations")
@export var start_graph_node_scene: PackedScene
@export var effect_graph_node_scene: PackedScene
@export var end_graph_node_scene: PackedScene

@onready var graph_edit: GraphEdit = %GraphEdit

func _ready() -> void:
	_clear_graph()
	populate_from_card_resource(card_resource)


func populate_from_card_resource(_card_resource: CardResourceV2) -> void:
	if not _card_resource:
		return
	_clear_graph()
	if not _card_resource.start_card_module:
		_add_modules_flat(_card_resource.get_card_modules())
		return

	var nodes_map: Dictionary = {}  # module.id -> node.name
	var levels := _get_modules_by_level(_card_resource.start_card_module)
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

			# Track modules without next_modules for end node connection
			if module.next_modules.is_empty():
				last_modules.append(module)

	# Create connections between modules
	_create_connections(_card_resource.start_card_module, nodes_map)

	# Add end node and connect it
	_add_end_node(last_modules, nodes_map, levels.size())


func _add_modules_flat(modules: Array[CardModule]) -> void:
	# Fallback for cards without start_card_module - display in a row
	for i in modules.size():
		var module := modules[i]
		var node := _create_graph_node(module)
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


func _create_graph_node(module: CardModule) -> GraphNode:
	var node: GraphNode
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
	end_node.position_offset = Vector2(level_count * NODE_SPACING_X, 0)

	graph_edit.add_child(end_node)

	# Connect last modules to end node
	for module in last_modules:
		if nodes_map.has(module.id):
			graph_edit.connect_node(nodes_map[module.id], 0, "end_node", 0)


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
			child.queue_free()


func get_card_modules() -> Array[CardModuleGraphNode]:
	var modules: Array[CardModuleGraphNode] = []
	for child in graph_edit.get_children():
		if child is CardModuleGraphNode:
			modules.append(child)
	return modules
