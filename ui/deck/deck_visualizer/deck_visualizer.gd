extends Control
class_name DeckVisualizer

@onready var deck_container_component: DeckContainerComponent = $MarginContainer/VBoxContainer/DeckContainerComponent
@onready var back_button: SoundButton = $MarginContainer/VBoxContainer/BackButton

@export var deck: Array[CardResourceV2] = []

func _ready() -> void:
	deck_container_component.init_deck_container_component(deck)
	back_button.pressed_and_sound_played.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	self.queue_free()
