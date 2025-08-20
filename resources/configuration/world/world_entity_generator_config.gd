extends Resource
class_name WorldEntityGeneratorConfig

@export var node_scene: PackedScene
@export var weight: int = 0
## TODO: need to find a way to add this
#@export var min_ocurrences: int = 0
@export var max_ocurrences: int = 100
@export var minimum_distance_to_root: int = 0
@export var maximimum_distance_to_root: int = 100

## Override node possible_rewards
@export var override_possible_rewards: WorldNodeRewardGeneratorConfig

func generate() -> Object:
	if not node_scene:
		return null
	var scene = node_scene.instantiate().duplicate()
	## TODO: override possible rewards
	if override_possible_rewards and scene is GenericWorldNode:
		scene.override_world_node_reward(
			override_possible_rewards.get_rewards(),
			override_possible_rewards.number_of_choices
		)
	return scene
	
func init_world_generator_config() -> void:
	if override_possible_rewards:
		override_possible_rewards.init_reward_generator_config()
