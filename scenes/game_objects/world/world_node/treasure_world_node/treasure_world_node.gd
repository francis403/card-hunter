extends GenericWorldNode
class_name TreasureWorldNode

## TODO: we probably need to add this somehow to the generator config
@export_group("Treasure Rewards Configuration")
## Possible treasure contents
@export var possible_treasure_content: Array[CardResourceV2] = []
@export var number_of_rewards: int = 3
@export var number_of_choices: int = 2
	
## If true, the treasure will return the contents of treasure_content
@export var _specify_treasure_content: bool = false
## Specify the actual treasure content
@export var treasure_content: Array[CardResourceV2] = []

## -------- OVERRIDE IMNPORTANT FUNCTIONS --------
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/treasure_world_node/treasure_world_node.tscn"
	
## Get's called by the generator when we specify in the world generator config that we want to override it
func override_world_node_reward(
	rewards: Array[CardResourceV2],
	_number_of_choices: int
):
	_specify_treasure_content = true
	treasure_content.append_array(rewards)
	self.number_of_choices = _number_of_choices
	
## -------- FINISH OVERRIDING IMNPORTANT FUNCTIONS --------

func get_world_node_rewards() -> Array[CardResourceV2]:
	var result: Array[CardResourceV2] = []
	if _specify_treasure_content and treasure_content:
		return treasure_content
	if not possible_treasure_content or possible_treasure_content.is_empty():
		for i in range(0, number_of_rewards):
			result.append(CardResourcesController.get_random_card())
		return result
	for i in range(0, number_of_rewards):
		result.append(possible_treasure_content.pick_random())
	return result

func _on_scene_exited_signal():
	BattlemapSignals.node_completed_and_freed.emit(self.world_node_id)
