extends CardEffect
class_name CardEffectWithCardSelection

@export_group("Discard configuration")
@export var number_of_cards_to_select: int = 1

var selected_cards: Array[Card] = []

func play_card_effect() -> bool:
	before_user_input()
	var selected_card: Card = await _get_user_input()
	if not selected_card:
		return false
	card_effect()
	_after_card_effect()
	return true

func _get_user_input() -> Card:
	
	## Show the Select Card option on the menu
	var _ignore_card_list: Array[Card] = []
	if BattleController._current_card_being_played:
		_ignore_card_list.append(BattleController._current_card_being_played)
	BattlemapSignals.awaiting_for_card_selection.emit(
		_ignore_card_list
	)
	
	## TODO: Highlight possible cards
	
	var selected_card: Card = null
	selected_card = await BattlemapSignals.card_selected_confirmed
	if selected_card:
		selected_cards.append(selected_card)
	return selected_card
	

## Override to define the behaviour before the user is asked for input
func before_user_input():
	selected_cards.clear()

## Override to define the card_effect after the user input
func card_effect():
	pass

## Override to define what happens after the card effect is played
func _after_card_effect():
	pass
