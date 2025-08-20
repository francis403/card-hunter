extends Resource
class_name WorldNodeRewardGeneratorConfig

## Weighted table with all the possible rewards
@export var override_possible_rewards: Array[WorldEntityRewardGeneratorConfig]
## The number of rewards that get presented to the player
@export var number_of_rewards_to_display: int = 2
## The number of choices the player can have
@export var number_of_choices: int = 1

var _possible_rewards_table: WeightedTable = WeightedTable.new()

func init_reward_generator_config() -> void:
	if override_possible_rewards and not override_possible_rewards.is_empty():
		self._possible_rewards_table = self._initialize_possible_rewards_override()

func _initialize_possible_rewards_override() -> WeightedTable:
	var result: WeightedTable = WeightedTable.new()
	for possible_reward_config in override_possible_rewards:
		result.add_item(
			possible_reward_config, 
			possible_reward_config.weight
		)
	return result
	
## TODO: add the maximum/minimum possible rewards
func get_rewards() -> Array[CardResourceV2]:
	var result: Array[CardResourceV2] = []
	for i in range(0, number_of_rewards_to_display):
		var possible_reward_config: WorldEntityRewardGeneratorConfig = _possible_rewards_table.pick_item()
		result.append(possible_reward_config.reward_resource)
	return result
