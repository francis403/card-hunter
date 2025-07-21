extends Control
class_name DeckVisualizer

@onready var deck_container_component: DeckContainerComponent = $MarginContainer/VBoxContainer/DeckContainerComponent

@export var deck: Array[CardResourceV2] = []

func _ready() -> void:
	deck_container_component.init_deck_container_component(deck)

func _on_back_button_pressed() -> void:
	self.queue_free()
