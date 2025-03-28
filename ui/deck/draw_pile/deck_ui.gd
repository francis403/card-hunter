extends Control
class_name DeckUI

const deck_visualizer_scene = preload("res://ui/deck/deck_visualizer/deck_visualizer.tscn")

enum Deck_Type_Enum {
	FULL_DECK,
	DRAW_DECK,
	DISCARD_DECK
}

@export var title: String = "Draw Pile"
@export var deck_type: Deck_Type_Enum = Deck_Type_Enum.DRAW_DECK

@onready var title_label: Label = %Title
@onready var number_of_cards_label: Label = %NumberOfCards
@onready var margin_container: MarginContainer = $MarginContainer


func _ready() -> void:
	if deck_type == Deck_Type_Enum.DRAW_DECK:
		BattlemapSignals.draw_pile_updated.connect(_on_deck_finished_prepping_signal)
		#margin_container.add_theme_constant_override("margin_left", self.size.y)
	elif deck_type == Deck_Type_Enum.DISCARD_DECK:
		BattlemapSignals.discard_pile_updated.connect(_on_deck_finished_prepping_signal)
	elif deck_type == Deck_Type_Enum.FULL_DECK:
		BattlemapSignals.full_deck_updated.connect(_on_deck_finished_prepping_signal)
		number_of_cards_label.text = str(PlayerController.get_deck().get_size())
		
	title_label.text = title
	#number_of_cards_label.text = str(_deck.size())

func _on_deck_finished_prepping_signal(
	deck: Array[CardResource]
):
	number_of_cards_label.text = str(deck.size())


func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		if deck_type == Deck_Type_Enum.DRAW_DECK:
			BattlemapSignals.show_draw_pile_deck.emit()
		elif deck_type == Deck_Type_Enum.DISCARD_DECK:
			BattlemapSignals.show_discard_pile_deck.emit()
		elif deck_type == Deck_Type_Enum.FULL_DECK:
			## TODO: add window to show full deck
			_show_full_deck()
			

func _show_full_deck():
	var deck_visualizer_instance: DeckVisualizer = Constants.deck_visualizer_scene.instantiate()
	deck_visualizer_instance.deck = PlayerController.get_deck()._deck
	get_tree().root.add_child(deck_visualizer_instance)
