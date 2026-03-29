extends Control
class_name CardpediaScreen

# Hub screen for the Cardpedia feature.
# Presents three category entry points: unlocked cards, bestiary, and forged cards.
# Sub-screens are not yet implemented – buttons are wired but navigate nowhere for now.
#
# Signal connections are declared entirely in the .tscn file; _ready() does NOT
# duplicate them here, which would cause every handler to fire twice in Godot 4.

# ── Navigation ────────────────────────────────────────────────────────────────

func _on_back_pressed() -> void:
	# Constants is the project-wide source of truth for scene paths –
	# matches the pattern used by every other screen (e.g. title_scene.gd).
	get_tree().change_scene_to_packed(Constants.title_scene)

func _on_my_cards_pressed() -> void:
	pass # TODO: open unlocked-cards screen

func _on_bestiary_pressed() -> void:
	pass # TODO: open monster bestiary screen

func _on_forged_cards_pressed() -> void:
	pass # TODO: open forged-cards screen