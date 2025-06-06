extends Condition

## TODO: still has a bug where all the cards played are considered discarded.
## Card cannot be the first n-played
class_name NumberOfCardsPlayedCondition

@export var minimum_number_of_cards_played: int = 1

func is_condition_meet() -> bool:
	return BattleController.player_turn_stats.total_number_of_cards_played >= minimum_number_of_cards_played
