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

## Contains the description on how to generate the world nodes by min-level
var _possible_node_configs_by_distance: Dictionary = {
	0: WeightedTable.new()
}
var _inserted_min_distances: Array[int] = [0]

var _possible_boss_monsters_configs: WeightedTable = WeightedTable.new()

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

## TODO: we need to generate the nodes
## Maybe it would be smarter to not try to determine which nodes we should add straight from the start,
## but only when it's clicked
func _generate_node_list():
	pass

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

## TODO: need to think of some logic to have min-max number of nodes
## Maybe a possible solution would be to start by making them all MonsterHuntNode, and then move through the list of required nodes
func generate_node(
	distance: int
) -> GenericWorldNode:
	var random_distance: int = randi_range(0, distance)
	var random_index: int = _get_weighted_table_index(random_distance, _inserted_min_distances)
	var random_weighted_table: WeightedTable = _possible_node_configs_by_distance[random_index]
	var random_config: WorldEntityGeneratorConfig = random_weighted_table.pick_item()
	if not random_config:
		print("ERROR: no random_config")
		return null;
	var world_node_scene: GenericWorldNode = random_config.generate()
	if not world_node_scene:
		print("ERROR: no world_node_scene")
		return null;
	
	_add_to_generated_history(
		world_node_scene.world_node_id,
		_generated_nodes
	)
	_remove_from_possible_if_max_reached(
		world_node_scene.world_node_id,
		random_config.max_ocurrences,
		random_index,
		_possible_node_configs_by_distance,
		_inserted_min_distances,
		_generated_nodes
	)
	_initialize_world_node_scene(world_node_scene, distance)
	
	return world_node_scene

## TODO: we could do this in log n
func _get_weighted_table_index(
	distance: int,
	_inserted_distances: Array[int],
) -> int:
	var found_i: int = 0
	## I'm not sure this always follows the order of insertion
	for _inserted_min_distance in _inserted_distances:
		if _inserted_min_distance > distance:
			continue
		else:
			found_i = _inserted_min_distance
	return found_i

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
	index_to_remove: int,
	dictionary_to_remove_from: Dictionary,
	inserted_distances: Array[int],
	generated_history: Dictionary
):
	if not generated_history.has(id):
		return
	var number_of_generated: int = generated_history[id]
	if number_of_generated >= max_generated:
		## remove
		dictionary_to_remove_from.erase(index_to_remove)
		
		## TODO: improve this
		var index: int = 0
		for i in range(inserted_distances.size()):
			if inserted_distances[i] == index_to_remove:
				index = i
				break
		inserted_distances.remove_at(index)

func _initialize_world_node_scene(
	world_node_scene: GenericWorldNode,
	distance: int = 0
):
	if world_node_scene is MonsterHuntWorldNode:
		var random_monster: GenericMonster = self._generate_monster(distance)
		world_node_scene.monsters_in_node.append(random_monster)
		return
	
		
func _generate_monster(
	distance: int
) -> GenericMonster:
	var random_distance: int = randi_range(0, distance)
	var random_index: int = _get_weighted_table_index(random_distance, _inserted_monsters_min_distances)
	var random_weighted_table: WeightedTable = _possible_monsters_configs_by_distance[random_index]
	var random_config: WorldEntityGeneratorConfig = random_weighted_table.pick_item()
	if not random_config:
		print("ERROR: no random_config")
		return null;
	var monster_scene: GenericMonster = random_config.generate()
	if not monster_scene:
		print("ERROR: no monster_scene")
		return null;
	
	_add_to_generated_history(monster_scene.monster_id, _generated_monsters)
	_remove_from_possible_if_max_reached(
		monster_scene.monster_id,
		random_config.max_ocurrences,
		random_index,
		_possible_monsters_configs_by_distance,
		_inserted_monsters_min_distances,
		_generated_monsters
	)
	return monster_scene
	
