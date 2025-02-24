extends Control

@onready var player_health_label: Label = $HBoxContainer/VBoxContainer/PlayerHealthLabel
@onready var player_stamina_label: Label = $HBoxContainer/VBoxContainer/PlayerStaminaLabel
@onready var end_turn_button: Button = %EndTurnButton

func _ready() -> void:
	BattlemapSignals.player_stamina_changed.connect(_on_player_stamina_changed)


func _on_player_stamina_changed(current_stamina: int):
	player_stamina_label.text = "Stamina: " + str(current_stamina)


func _on_end_turn_button_pressed() -> void:
	BattleController.end_button_pressed()
