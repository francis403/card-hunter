extends Resource

## Defines how the WorldGeneratorManager should create the world
## There is still a lot of work that needs to be done here
class_name WorldGeneratorConfig

@export var available_world_nodes: Array[WorldNodeGeneratorConfig] = []
@export var available_generic_monsters: Array[WorldMonsterGeneratorConfig] = []
@export var max_distance_to_village = 1
@export var max_number_of_child_nodes = 3

## Contains the description on how to generate the world nodes by min-level
var _possible_node_configs_by_distance: Dictionary = {
	0: WeightedTable.new()
}
var _inserted_min_distances: Array[int] = [0]

## This can be used to check the maximum and the minimum number of nodes
## WorldNode Id - Number of nodes generated
var _generated_nodes: Dictionary = {
	"node_id": 0 
}

func initialize_config():
	_initialize_world_node_config()
	_initialize_world_monster_config()
	#_generate_possible_nodes_by_level()

## TODO: we need to generate the nodes
## Maybe it would be smarter to not try to determine which nodes we should add straight from the start,
## but only when it's clicked
func _generate_node_list():
	pass

func _initialize_world_node_config():
	_possible_node_configs_by_distance.clear()
	for world_node_config in available_world_nodes:
		var min_dist: int = world_node_config.minimum_distance_to_root
		if _possible_node_configs_by_distance.has(min_dist):
			_possible_node_configs_by_distance[min_dist].add_item(world_node_config, world_node_config.weight)
		else:
			_possible_node_configs_by_distance[min_dist] = WeightedTable.new()
			_possible_node_configs_by_distance[min_dist]\
				.add_item(
					world_node_config,
					world_node_config.weight
				)
			_inserted_min_distances.append(min_dist)
	_inserted_min_distances.sort()

func _initialize_world_monster_config():
	pass


## TODO: need to think of some logic to have min-max number of nodes
func generate_node(
	distance: int
) -> GenericWorldNode:
	var random_distance: int = randi_range(0, distance)
	var random_index: int = _get_world_node_weighted_table(random_distance)
	var random_weighted_table: WeightedTable = _possible_node_configs_by_distance[random_index]
	var random_config: WorldNodeGeneratorConfig = random_weighted_table.pick_item()
	if not random_config:
		print("ERROR: no random_config")
		return null;
	var world_node_scene: GenericWorldNode = random_config.node_scene.instantiate().duplicate()
	if not world_node_scene:
		print("ERROR: no world_node_scene")
		return null;
	
	_add_to_generated_nodes_history(world_node_scene.world_node_id)
	_remove_from_possible_nodes_if_max_reached(
		world_node_scene.world_node_id,
		random_config.max_ocurrences,
		random_index
	)
	_initialize_world_node_scene(world_node_scene)
	
	return world_node_scene

## TODO: we could do this in log n
func _get_world_node_weighted_table(
	distance: int
) -> int:
	var found_i: int = 0
	## I'm not sure this always follows the order of insertion
	for _inserted_min_distance in _inserted_min_distances:
		if _inserted_min_distance > distance:
			continue
		else:
			found_i = _inserted_min_distance
	return found_i

func _add_to_generated_nodes_history(id: String):
	if _generated_nodes.has(id):
		var current_number = _generated_nodes.get(id)
		_generated_nodes[id] = current_number + 1
	else:
		_generated_nodes[id] = 1

func _remove_from_possible_nodes_if_max_reached(
	id: String,
	max_generated: int,
	index_to_remove: int
):
	if not _generated_nodes.has(id):
		return
	var number_of_generated: int = _generated_nodes[id]
	if number_of_generated >= max_generated:
		## remove
		_possible_node_configs_by_distance.erase(index_to_remove)
		
		## TODO: improve this
		var index: int = 0
		for i in range(_inserted_min_distances.size()):
			if _inserted_min_distances[i] == index_to_remove:
				index = i
				break
		_inserted_min_distances.remove_at(index)

func _get_number_of_nodes_generated(id: String) -> int:
	if not _generated_nodes.has(id):
		return 0
	return _generated_nodes[id]

## TODO: this is obviously not good
func _initialize_world_node_scene(
	world_node_scene: GenericWorldNode
):
	## TODO: improve this
	if world_node_scene is MonsterHuntWorldNode:
		var random_monster: GenericMonster = MonsterResourcesController.get_random_generic_monster()
		world_node_scene.monsters_in_node.append(random_monster)
	if world_node_scene is TreasureWorldNode:
		return
