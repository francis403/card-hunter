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
		#margin_container.add_theme_constant_override("margin_right", 1000)
	title_label.text = title
	#number_of_cards_label.text = str(_deck.size())

func _on_deck_finished_prepping_signal(
	deck: Array[CardResource]
):
	number_of_cards_label.text = str(deck.size())


func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		print("Show deck")
		if deck_type == Deck_Type_Enum.DRAW_DECK:
			BattlemapSignals.show_draw_pile_deck.emit()
		elif deck_type == Deck_Type_Enum.DISCARD_DECK:
			BattlemapSignals.show_discard_pile_deck.emit()
		elif deck_type == Deck_Type_Enum.FULL_DECK:
			BattlemapSignals.show_full_deck.emit()
			
		#var deck_visualizer_instance: DeckVisualizer = deck_visualizer_scene.instantiate()
		##deck_visualizer_instance.deck =
		#self.get_parent().get_parent().add_child(deck_visualizer_instance)
