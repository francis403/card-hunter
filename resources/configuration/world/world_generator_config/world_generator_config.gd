extends Resource

## Defines how the WorldGeneratorManager should create the world
## There is still a lot of work that needs to be done here
class_name WorldGeneratorConfig

@export var available_world_nodes: Array[WorldEntityGeneratorConfig] = []
@export var available_generic_monsters: Array[WorldEntityGeneratorConfig] = []
@export var available_boss_monsters: Array[WorldEntityGeneratorConfig] = []
@export var max_distance_to_village = 2
@export var max_number_of_child_nodes = 3
@export var number_of_village_children_node = 3

@export var _debug_mode: bool = false

## Contains the description on how to generate the world nodes by min-level
var _possible_node_configs_by_distance: Dictionary = {
	0: WeightedTable.new()
}
var _inserted_min_distances: Array[int] = [0]

var _possible_boss_monsters_configs: WeightedTable = WeightedTable.new()

## Distance - WeightedTable reference.
var _possible_monsters_configs_by_distance: Dictionary = {
	0: WeightedTable.new()
}

var _inserted_monsters_min_distances: Array[int] = [0]

## This can be used to check the maximum and the minimum number of nodes
## WorldNode Id - Number of nodes generated
var _generated_nodes: Dictionary = {
	"node_id": 0 
}
var _generated_monsters: Dictionary = {
	"monster_id": 0 
}

func initialize_config():
	_possible_node_configs_by_distance =\
		_initialize_world_entity_config(available_world_nodes, _inserted_min_distances)
	_possible_monsters_configs_by_distance =\
		_initialize_world_entity_config(available_generic_monsters, _inserted_monsters_min_distances)
	_possible_boss_monsters_configs = _initialize_boss_monsters_config()

func _initialize_world_entity_config(
	world_entity_configs: Array[WorldEntityGeneratorConfig],
	inserted_distances: Array[int]
) -> Dictionary:
	var result: Dictionary = {}
	inserted_distances.clear()
	for world_entity_config in world_entity_configs:
		world_entity_config.init_world_generator_config()
		var min_dist: int = world_entity_config.minimum_distance_to_root
		if result.has(min_dist):
			result[min_dist].add_item(
				world_entity_config,
				world_entity_config.weight
			)
		else:
			result[min_dist] = WeightedTable.new()
			result[min_dist]\
				.add_item(
					world_entity_config,
					world_entity_config.weight
				)
			inserted_distances.append(min_dist)
	inserted_distances.sort()
	return result

func _initialize_boss_monsters_config() -> WeightedTable:
	var result: WeightedTable = WeightedTable.new()
	for boss_monster_config in available_boss_monsters:
		result.add_item(
			boss_monster_config, 
			boss_monster_config.weight
		)
	return result

func generate_random_boss_monster_scene() -> PackedScene:
	var boss_monster_config: WorldEntityGeneratorConfig = _possible_boss_monsters_configs.pick_item()
	if boss_monster_config:
		return boss_monster_config.node_scene
	return null

func _generate_monster(
	distance: int
) -> GenericMonster:
	if _debug_mode:
		print("DEBUG: Generate Monster start")
	var random_distance_by_weight: int = _get_random_weighted_table_index(distance, _inserted_monsters_min_distances)
	if random_distance_by_weight < 0:
		push_warning(_generate_monster, " _possible_monsters_configs_by_distance is empty! Probably not enough monsters per monster hunt node")
		return null
	var random_weighted_table: WeightedTable = _possible_monsters_configs_by_distance[random_distance_by_weight]
	var random_config_dictionary: Dictionary = random_weighted_table.pick_dictionary()
	var index_to_remove_from: int = random_config_dictionary["index"]
	var random_config: WorldEntityGeneratorConfig = random_config_dictionary["item"]
	if not random_config:
		push_error(_generate_monster, " ERROR: no random_config")
		return null;
	var monster_scene: GenericMonster = random_config.generate()
	if not monster_scene:
		push_error(_generate_monster, " ERROR: no monster_scene")
		return null;
	_add_to_generated_history(monster_scene.monster_id, _generated_monsters)
	#print_debug("Monster ", monster_scene.monster_id, " added! Total of: ", _generated_monsters[monster_scene.monster_id], " added!")
	_remove_from_possible_if_max_reached(
		monster_scene.monster_id,
		random_config.max_ocurrences,
		random_distance_by_weight,
		index_to_remove_from,
		_possible_monsters_configs_by_distance,
		_inserted_monsters_min_distances,
		_generated_monsters
	)
	return monster_scene

## Provided a distance of a node from the center, generate a possible node
func generate_node(
	distance: int
) -> GenericWorldNode:
	## Grab random distance between the root and the center
	## Grab all the available distances between the node and the root
	var random_distance_by_weight: int = _get_random_weighted_table_index(distance, _inserted_min_distances)
	if random_distance_by_weight < 0:
		return null
	var random_weighted_table: WeightedTable = _possible_node_configs_by_distance[random_distance_by_weight]
	var random_config_dictionary: Dictionary = random_weighted_table.pick_dictionary()
	var index_to_remove_from: int = random_config_dictionary["index"]
	var random_config: WorldEntityGeneratorConfig = random_config_dictionary["item"]
	if not random_config:
		push_error(generate_node, " ERROR: no random_config")
		return null
	var world_node_scene: GenericWorldNode = random_config.generate()
	if not world_node_scene:
		push_error(generate_node, " ERROR: no world_node_scene")
		return null
	
	_add_to_generated_history(
		world_node_scene.world_node_id,
		_generated_nodes
	)
	_remove_from_possible_if_max_reached(
		world_node_scene.world_node_id,
		random_config.max_ocurrences,
		random_distance_by_weight,
		index_to_remove_from,
		_possible_node_configs_by_distance,
		_inserted_min_distances,
		_generated_nodes
	)
	_initialize_world_node_scene(world_node_scene, distance)
	
	return world_node_scene

func get_min_node_distance() -> int:
	if _inserted_min_distances.is_empty():
		return -1
	return _inserted_min_distances[0]
	
func get_max_distance() -> int:
	return 1

func _get_random_weighted_table_index(
	distance: int,
	_inserted_distances: Array[int],
) -> int:
	var _possible_distances: Array[int] =\
		_inserted_distances.filter(func (_distance): return _distance <= distance)
	if not _possible_distances:
		if _debug_mode:
			print("DEBUG: distance ", distance, " not in _inserted_distances: ", _inserted_distances)
		push_warning("WARNING: distance ", distance, " not in _inserted_distances: ", _inserted_distances)
		return -1
	return _possible_distances.pick_random()

func _add_to_generated_history(
	id: String,
	_generated_history: Dictionary
):
	if _generated_history.has(id):
		var current_number = _generated_history.get(id)
		_generated_history[id] = current_number + 1
	else:
		_generated_history[id] = 1

func _remove_from_possible_if_max_reached(
	id: String,
	max_generated: int,
	distance_to_remove_from: int,
	index_in_distance_to_remove_from: int,
	dictionary_to_remove_from: Dictionary,
	inserted_distances: Array[int],
	generated_history: Dictionary
):
	if not generated_history.has(id):
		if _debug_mode:
			print("DEBUG: Tried removing ", id, " but it's not in generated history so skipping!")
		return
	var number_of_generated: int = generated_history[id]
	if number_of_generated >= max_generated:
		## remove
		if _debug_mode:
			print("DEBUG: removing dictionary_to_remove_from[", distance_to_remove_from ,"] index: ", index_in_distance_to_remove_from)
		dictionary_to_remove_from[distance_to_remove_from].remove_item_by_index(index_in_distance_to_remove_from)
		if not dictionary_to_remove_from[distance_to_remove_from].is_empty():
			return
		dictionary_to_remove_from.erase(distance_to_remove_from)
		var index: int = inserted_distances.find(distance_to_remove_from)
		if index >= 0:
			if _debug_mode:
				print("DEBUG: removing inserted_distances[",index, "]")
			inserted_distances.remove_at(index)
	if _debug_mode:
		print("DEBUG: (", id, ", ", number_of_generated ,", ", max_generated, ")")

func _initialize_world_node_scene(
	world_node_scene: GenericWorldNode,
	distance: int = 0
):
	if world_node_scene is MonsterHuntWorldNode:
		var random_monster: GenericMonster = self._generate_monster(distance)
		if not random_monster:
			push_error("ERROR: Error while generating Monster for MonsterHuntWorld")
		world_node_scene.monsters_in_node.append(random_monster)
		return
	
