extends Node2D

## Handles the world generation & the world loading from save file
## TODO: Need to divide this class in two (world_generation / world loading)
class_name WorldGeneratorManager

const VILLAGE_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/village_world_node/village_world_node.tscn")

const RADIUS = 30

@export var world_generator_config: WorldGeneratorConfig

@export_category("World Generation Specification")

@export_category("World Generation UI")
@export var seperation: int = 100
@export var world_node_container: Container
@export var village_node_marker: Marker2D

var total_number_of_nodes_generated: int = 0
var max_distance_to_village: int = 2
var maximum_number_of_child_nodes: int = 3

## TODO: need to urgenlty improve this, this is not a smart way to check for node overllaping
## Used as a helper to make sure we have no nodes overllaping
#var _generated_nodes: Array[MonsterHuntWorldNode] = []
var _generated_nodes: Array[GenericWorldNode] = []
var _min_position_difference: float = 20.0

var _loaded_nodes: Array[String] = []

## an instance of the world's root node
var village_node: VillageWorldNode

func _init() -> void:
	village_node = File.progress.village_node

func _ready() -> void:
	BattlemapSignals.world_updated.connect(_save_world_state)
	if world_generator_config:
		world_generator_config.initialize_config()
		max_distance_to_village = world_generator_config.max_distance_to_village
		maximum_number_of_child_nodes = world_generator_config.max_number_of_child_nodes

#func _draw():
	#if not _is_world_saved():
		#_generate_world()
	#else:
		#_load_world()

func _exit_tree() -> void:
	## on exit need to make sure not to delete the village node
	if File.progress:
		File.progress.village_node = village_node.duplicate_node(true)

func _is_world_saved() -> bool:
	return village_node != null	

func _remove_preview():
	if not world_node_container:
		return
	for node in world_node_container.get_children():
		node.queue_free()
		
func _generate_world():
	print(_generate_world)
	if not world_generator_config:
		return
	_generate_village()
	_generate_adjacent_nodes(
		village_node,
		world_generator_config.max_number_of_child_nodes,
		1
	)
	village_node.reveal_connected_nodes()
	_save_world_state()
	
func _draw_line_between_nodes(base_node: GenericWorldNode, other_node: GenericWorldNode):
	var angle: float = base_node.global_position.angle_to_point(other_node.global_position)
	var offset: Vector2 = Vector2(-1 * RADIUS, 0)
	draw_line(
		base_node.global_position, 
		other_node.global_position + offset.rotated(angle), 
		Color.BLACK
	)
	
func _generate_village():
	village_node = VILLAGE_NODE_SCENE.instantiate()
	village_node.world_node_id = Constants.VILLAGE_NODE_ID
	village_node.is_showing_player_sprite = true
	village_node.is_revealed = true
	village_node.is_reachable = true
	village_node.global_position = village_node_marker.global_position
	world_node_container.add_child(village_node)
	PlayerController.current_world_node = village_node

## TODO: What if we add the position first, 
## and then go through all of them to add the minimum and maximum
## We count the number of nodes total and then actually gneerate them
func _generate_adjacent_nodes(
	base_node: GenericWorldNode,
	number_of_children: int = self.maximum_number_of_child_nodes,
	current_build_depth: int = 0
):
	for i in range(base_node.connections.size(), number_of_children):
		var generated_position: Vector2 = get_node_iteration_position(base_node, i)
		var overllaping_node: GenericWorldNode = get_overlapping_node(generated_position)
		if overllaping_node:
			base_node.connections.append(overllaping_node)
			_draw_line_between_nodes(base_node, overllaping_node)
			continue
		var generated_node: GenericWorldNode = world_generator_config.generate_node(current_build_depth)
		generated_node.global_position = generated_position
		generated_node.world_node_id = str(total_number_of_nodes_generated)
		base_node.connections.append(generated_node)
		world_node_container.add_child(generated_node)
		_generated_nodes.append(generated_node)
		total_number_of_nodes_generated += 1
		_draw_line_between_nodes(base_node, generated_node)
		if current_build_depth < max_distance_to_village:
			_generate_adjacent_nodes(
				generated_node,
				2,
				current_build_depth + 1
			)

## Get the first overlapping node
func get_overlapping_node(world_node_global_position: Vector2) -> GenericWorldNode:
	for generated_node in _generated_nodes:
		if world_node_global_position.distance_to(generated_node.global_position) < _min_position_difference:
			return generated_node
	return null

func _load_world():
	print(_load_world)
	_load_village()
	BattlemapSignals.hide_player_in_other_node.emit(File.progress.current_world_node_id)

func _load_village():
	village_node = File.progress.village_node
	_initiate_world(village_node)

func _initiate_world(base_node: GenericWorldNode):
	## TODO: need to improve this
	if _loaded_nodes.has(base_node.world_node_id):
		return
	_loaded_nodes.append(base_node.world_node_id)
	world_node_container.add_child(base_node)
	if base_node.is_showing_player_sprite:
		PlayerController.current_world_node = base_node
	for child in base_node.connections:
		_initiate_world(child)
		_draw_line_between_nodes(base_node, child)
	
func get_node_iteration_position(center_node: GenericWorldNode, iteration: int) -> Vector2:
	var partition: float =  (float(iteration + 1)/ maximum_number_of_child_nodes)
	var angle: float = partition * TAU
	var position_offset: Vector2 = Vector2(seperation, 0).rotated(angle)
	return center_node.global_position + position_offset

func get_random_world_boss_scene() -> PackedScene:
	if not world_generator_config:
		return null
	return world_generator_config.generate_random_boss_monster_scene()

func _save_world_state():
	print(_save_world_state)
	File.progress.village_node = village_node
	File.progress.world_state.convert_node_to_world_state(village_node)
