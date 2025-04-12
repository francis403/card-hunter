extends Node2D

## Handles the world generation & the world loading from save file
## TODO: Need to divide this class in two (world_generation / world loading)
class_name WorldGeneratorManager

const WORLD_NODE_SCENE = preload("res://scenes/game_objects/world/world_node/world_node.tscn")
const BATTLE_ONE_CRAB_SCENE = preload("res://scenes/battle_scenes/battle_one_crab_scene.tscn/battle_one_crab_scene.tscn")
const CRAB_MONSTER_SCENE = preload("res://scenes/monsters/CrabMonster/crab_monster.tscn")
const SPIDER_MONSTER_SCENE = preload("res://scenes/monsters/spider_monster/spider_monster.tscn")
const RADIUS = 30

@export_category("World Generation Specification")
@export var seed: String = ""
@export var max_distance_to_village: int = 1
@export var maximum_number_of_child_nodes: int = 3

@export_category("World Generation UI")
@export var seperation: int = 100
@export var world_node_container: Container
@export var village_node_marker: Marker2D

var total_number_of_nodes_generated: int = 0

## TODO: need to urgenlty improve this, this is not a smart way to check for node overllaping
## Used as a helper to make sure we have no nodes overllaping
var _generated_nodes: Array[WorldNode] = []
var _min_position_difference: float = 20.0

var _loaded_nodes: Array[String] = []

## an instance of the world's root node
var village_node: WorldNode

func _init() -> void:
	village_node = File.progress.village_node

func _ready() -> void:
	print(_ready)
	BattlemapSignals.world_updated.connect(_save_world_state)
	#_remove_preview()

func _draw():
	if not _is_world_saved():
		_generate_world()
	else:
		_load_world()

func _exit_tree() -> void:
	## on exit need to make sure not to delete the village node
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
	_generate_village()
	_generate_adjacent_nodes(village_node, maximum_number_of_child_nodes, 1)
	BattlemapSignals.reveal_connected_nodes.emit(village_node)
	_save_world_state()
	
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
	village_node.world_node_id = Constants.VILLAGE_NODE_ID
	village_node.is_showing_player_sprite = true
	village_node.is_revealed = true
	village_node.is_reachable = true
	village_node.global_position = village_node_marker.global_position
	world_node_container.add_child(village_node)
	PlayerController.current_world_node = village_node

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
		
		var overllaping_node: WorldNode = get_overlapping_node(generated_node)
		if overllaping_node:
			base_node.connections.append(overllaping_node)
			_draw_line_between_nodes(base_node, overllaping_node)
			continue
		generated_node.world_node_id = str(total_number_of_nodes_generated)
		generated_node.quest_scene = BATTLE_ONE_CRAB_SCENE
		generated_node.monsters_in_node.append_array(_generate_random_monsters())
		base_node.connections.append(generated_node)
		world_node_container.add_child(generated_node)
		_generated_nodes.append(generated_node)
		total_number_of_nodes_generated += 1
		_draw_line_between_nodes(base_node, generated_node)
		if current_build_depth <= max_distance_to_village:
			_generate_adjacent_nodes(
				generated_node,
				2,
				current_build_depth + 1
			)

func _generate_random_monsters(max_number: int = 1) -> Array[GenericMonster]:
	var result: Array[GenericMonster] = []
	for i in max_number:
		var random_number: int = randi() % 2
		var monster: GenericMonster = null
		if random_number == 0:
			monster = CRAB_MONSTER_SCENE.instantiate()
		elif random_number == 1:
			monster = SPIDER_MONSTER_SCENE.instantiate()
		else:
			monster = CRAB_MONSTER_SCENE.instantiate()
		result.append(monster)
	return result
	

## Get the first overlapping node
func get_overlapping_node(world_node: WorldNode) -> WorldNode:
	var overlapping_nodes: Array[WorldNode] = []
	for generated_node in _generated_nodes:
		if world_node.global_position.distance_to(generated_node.global_position) < _min_position_difference:
			return generated_node
	return null

func _load_world():
	print(_load_world)
	_load_village()
	BattlemapSignals.hide_player_in_other_node.emit(File.progress.current_world_node_id)

func _load_village():
	print(_load_village)
	village_node = File.progress.village_node
	_initiate_world(village_node)
	print("after")

func _initiate_world(base_node: WorldNode):
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
	
func get_node_iteration_position(center_node: WorldNode, iteration: int) -> Vector2:
	var partition: float =  (float(iteration + 1)/ maximum_number_of_child_nodes)
	var angle: float = partition * TAU
	var position_offset: Vector2 = Vector2(seperation, 0).rotated(angle)
	return center_node.global_position + position_offset

func _save_world_state():
	print(_save_world_state)
	File.progress.village_node = village_node
	File.progress.world_state.convert_node_to_world_state(village_node)
