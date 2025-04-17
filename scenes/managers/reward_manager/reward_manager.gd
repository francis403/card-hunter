extends Node

## Manages which rewards are given once the battle is over
class_name RewardManager

@export var card_rewards: Array[CardResource] = []

func get_random_cards(number_of_cards: int = 2) -> Array[CardResource]:
	if card_rewards.size() == 0:
		return []
		
	var rewards: Array[CardResource] = []
	rewards.append(card_rewards.pick_random().duplicate())
	rewards.append(card_rewards.pick_random().duplicate())
	return rewards
