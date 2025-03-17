extends Control
class_name QuestPickerScreen

func _ready() -> void:
	BattlemapSignals.show_full_deck.connect(_on_show_full_deck_signal)
	BattlemapSignals.full_deck_updated.emit(PlayerController.get_deck()._deck)


func _on_show_full_deck_signal():
	var deck_visualizer_instance: DeckVisualizer = Constants.deck_visualizer_scene.instantiate()
	deck_visualizer_instance.deck = PlayerController.get_deck()._deck
	self.add_child(deck_visualizer_instance)
