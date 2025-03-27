extends Control
class_name QuestPickerScreen

## TODO: I don't think I should be sending this signal here
func _ready() -> void:
	BattlemapSignals.full_deck_updated.emit(PlayerController.get_deck()._deck)
