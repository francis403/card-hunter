extends Control
class_name DeckUI

enum Deck_Type_Enum {
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
		#margin_container.add_theme_constant_override("margin_right", 1000)
	title_label.text = title
	#number_of_cards_label.text = str(_deck.size())

func _on_deck_finished_prepping_signal(
	deck: Array[CardResource]
):
	number_of_cards_label.text = str(deck.size())
