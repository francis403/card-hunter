extends Control
class_name DeckVisualizer

signal on_card_clicked(_card: Card)
signal on_back_button_clicked

@onready var deck_container_component: DeckContainerComponent = $MarginContainer/VBoxContainer/DeckContainerComponent
@onready var back_button: SoundButton = $MarginContainer/VBoxContainer/BackButton

@export var deck: Array[CardResourceV2] = []
@export var listen_for_card_clicks: bool = false

func _ready() -> void:
	deck_container_component.listen_for_card_clicks = listen_for_card_clicks
	deck_container_component.init_deck_container_component(deck)
	deck_container_component.card_clicked.connect(_on_card_clicked_in_component)
	back_button.pressed_and_sound_played.connect(_on_back_button_pressed)

func _on_card_clicked_in_component(_card: Card):
	on_card_clicked.emit(_card)

func _on_back_button_pressed() -> void:
	on_back_button_clicked.emit()
	self.queue_free()
