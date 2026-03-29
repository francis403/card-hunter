extends Control
class_name CardpediaScreen

# Hub screen for the Cardpedia feature.
# Presents three category entry points: unlocked cards, bestiary, and forged cards.
# Sub-screens are not yet implemented – buttons are wired but navigate nowhere for now.

@onready var back_button: SoundButton = %BackButton
@onready var my_cards_button: SoundButton = %MyCardsButton
@onready var bestiary_button: SoundButton = %BestiaryButton
@onready var forged_cards_button: SoundButton = %ForgedCardsButton

func _ready() -> void:
	back_button.pressed_and_sound_played.connect(_on_back_pressed)
	my_cards_button.pressed_and_sound_played.connect(_on_my_cards_pressed)
	bestiary_button.pressed_and_sound_played.connect(_on_bestiary_pressed)
	forged_cards_button.pressed_and_sound_played.connect(_on_forged_cards_pressed)

# ── Navigation ────────────────────────────────────────────────────────────────

func _on_back_pressed() -> void:
	# Return to title menu
	get_tree().change_scene_to_packed(Refs.title_scene)

func _on_my_cards_pressed() -> void:
	pass # TODO: open unlocked-cards screen

func _on_bestiary_pressed() -> void:
	pass # TODO: open monster bestiary screen

func _on_forged_cards_pressed() -> void:
	pass # TODO: open forged-cards screen