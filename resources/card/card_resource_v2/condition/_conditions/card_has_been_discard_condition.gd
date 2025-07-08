extends Condition

## TODO: still has a bug where all the cards played are considered discarded.
## Card can only be played if a card has been discarded this turn
class_name CardHasBeenDiscardedCondition

func is_condition_meet() -> bool:
	return BattleController.player_turn_stats.total_number_of_cards_discarded > 0
