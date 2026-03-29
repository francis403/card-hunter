extends WorldGeneratorConfigManager
class_name RandomWorldGeneratorConfigManager

# ── Static scene paths – avoids instantiating node classes just to read the path (Issue 7) ──
const _MONSTER_HUNT_NODE_SCENE_PATH: String = \
	"res://scenes/game_objects/world/world_node/monster_hunt_world_node/monster_hunt_world_node.tscn"
const _TREASURE_NODE_SCENE_PATH: String = \
	"res://scenes/game_objects/world/world_node/treasure_world_node/treasure_world_node.tscn"
const _DEFORGE_NODE_SCENE_PATH: String = \
	"res://scenes/game_objects/world/world_node/deforge_card_world_node/deforge_card_world_node.tscn"

@export_range(5, 15) var _min_numbers_of_nodes_to_generate: int = 6
@export_range(5, 15) var _max_numbers_of_nodes_to_generate: int = 15

@export_range(1, 10) var _min_number_of_monster_types: int = 2
@export_range(1, 10) var _max_number_of_monster_types: int = 3

## Must cover the full layer range of the layered generator.
## The generator produces (min_middle_layers + 2) to (max_middle_layers + 2) layers.
## With max_middle_layers = 5 the max is 7, so this default must be >= 7.
## Keep this in sync with WorldNodesTableComponent.max_middle_layers. (Issue 2)
@export var _max_world_generation_depth: int = 7

## Possible boss monsters to be generated. Leave empty for full random
@export var _possible_boss_monsters: Array[PackedScene] = []
@export var _allow_duplicate_boss_monsters: bool = false

var _possible_boss_monsters_to_generates: Array[PackedScene] = []

var _random_weight_options: Array[int] = [5, 10, 10, 20, 30, 30, 40]
var _total_number_of_nodes_to_generate: int
var _total_number_of_monsters_added: int = 0

func _ready() -> void:
	for _packed_scene: PackedScene in _possible_boss_monsters:
		_possible_boss_monsters_to_generates.append(_packed_scene)

func generate_config() -> WorldGeneratorConfig:
	var _result: WorldGeneratorConfig = WorldGeneratorConfig.new()

	self._clear_context()

	_total_number_of_nodes_to_generate = randi_range(
		_min_numbers_of_nodes_to_generate,
		_max_numbers_of_nodes_to_generate
	)
	## Calculate number of other nodes
	var _number_of_special_nodes: int = _calculate_number_of_special_nodes()
	## Calculate number of monsters hunt node
	var _number_of_hunt_nodes: int = _total_number_of_nodes_to_generate - _number_of_special_nodes

	_result.available_generic_monsters = _get_monsters_entity_generator_config(_number_of_hunt_nodes)
	_result.available_boss_monsters    = _get_boss_monsters_entity_generator_config()
	_result.available_world_nodes      = _get_nodes_entity_generator_config()
	_result.max_distance_to_village    = self._max_world_generation_depth

	return _result

func _clear_context() -> void:
	_total_number_of_monsters_added = 0
	_total_number_of_nodes_to_generate = 0

func _calculate_number_of_special_nodes() -> int:
	## 1 treasure node + 2 deforge nodes
	return 3

func _get_nodes_entity_generator_config() -> Array[WorldEntityGeneratorConfig]:
	var _result: Array[WorldEntityGeneratorConfig] = []

	# Use constant paths instead of instantiating nodes to read their scene path (Issue 7)
	var _monster_hunter_packed_scene: PackedScene = load(_MONSTER_HUNT_NODE_SCENE_PATH)
	var _treasure_node_packed_scene: PackedScene   = load(_TREASURE_NODE_SCENE_PATH)
	var _deforge_node_packed_scene: PackedScene    = load(_DEFORGE_NODE_SCENE_PATH)

	## Monster hunt nodes
	_result.append(
		_generate_packed_entity_generator_config(
			_monster_hunter_packed_scene, _total_number_of_monsters_added
		)
	)
	## Treasure node
	_result.append(
		_generate_packed_entity_generator_config(_treasure_node_packed_scene, 1, 3)
	)
	## Deforge node
	_result.append(
		_generate_packed_entity_generator_config(_deforge_node_packed_scene, 2, 2)
	)

	return _result

func _get_monsters_entity_generator_config(
	_number_of_monsters_to_generate: int
) -> Array[WorldEntityGeneratorConfig]:
	var _result: Array[WorldEntityGeneratorConfig] = []
	var _nbr_of_monster_types: int = randi_range(
		_min_number_of_monster_types,
		_max_number_of_monster_types
	)

	var _list_of_generic_monsters: Array[GenericMonster] = \
		MonsterResourcesController.get_list_of_generic_monsters(_nbr_of_monster_types)
	for i in range(0, _nbr_of_monster_types):
		var _random_number_of_monster_node: int = \
			ceil(_number_of_monsters_to_generate / _nbr_of_monster_types)
		var _world_entity_config: WorldEntityGeneratorConfig = _generate_entity_generator_config(
			_list_of_generic_monsters.pop_front(),
			_random_number_of_monster_node
		)
		_total_number_of_monsters_added += _world_entity_config.min_occurrences
		_result.append(_world_entity_config)
	return _result

## Builds the boss-monster config array.
## Guards against an empty pool so a null scene never reaches the config (Issue 1).
func _get_boss_monsters_entity_generator_config() -> Array[WorldEntityGeneratorConfig]:
	var _result: Array[WorldEntityGeneratorConfig] = []

	if _possible_boss_monsters_to_generates.is_empty():
		# No boss scenes configured – skip boss config entirely to avoid a null crash.
		# TODO(FA): implement MonsterResourcesController.get_random_boss_monster() fallback.
		push_error("RandomWorldGeneratorConfigManager: _possible_boss_monsters is empty. "
			+ "Assign at least one boss scene in the Inspector.")
		return _result  # Caller (WorldGeneratorConfig) must handle missing boss config gracefully.

	var _picked_boss_monster: PackedScene
	if _allow_duplicate_boss_monsters:
		_picked_boss_monster = _possible_boss_monsters_to_generates.pick_random()
	else:
		_picked_boss_monster = _possible_boss_monsters_to_generates.pop_at(
			randi_range(0, _possible_boss_monsters_to_generates.size() - 1)
		)

	var _world_entity_config: WorldEntityGeneratorConfig = \
		_generate_packed_entity_generator_config(_picked_boss_monster, 1)
	_result.append(_world_entity_config)
	return _result

func _generate_entity_generator_config(
	_scene_node: Node,
	_number_of_occurrences: int = 2,
	_min_distance: int = 1,
	_max_distance: int = 6
) -> WorldEntityGeneratorConfig:
	var _result: WorldEntityGeneratorConfig = WorldEntityGeneratorConfig.new()
	var _packed_scene: PackedScene = PackedScene.new()
	_packed_scene.pack(_scene_node)
	return _generate_packed_entity_generator_config(
		_packed_scene, _number_of_occurrences, _min_distance, _max_distance
	)

func _generate_packed_entity_generator_config(
	_packed_scene: PackedScene,
	_number_of_occurrences: int = 2,
	_min_distance: int = 1,
	_max_distance: int = 6
) -> WorldEntityGeneratorConfig:
	var _result: WorldEntityGeneratorConfig = WorldEntityGeneratorConfig.new()
	_result.node_scene                    = _packed_scene
	_result.weight                        = _random_weight_options.pick_random()
	_result.min_occurrences               = _number_of_occurrences
	_result.max_ocurrences                = _number_of_occurrences
	_result.minimum_distance_to_root      = _min_distance
	_result.maximimum_distance_to_root    = _max_distance
	return _result