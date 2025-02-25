extends Control
class_name PlayerStatsUi

@onready var player_health_label: Label = $HBoxContainer/VBoxContainer/PlayerHealthLabel
@onready var player_stamina_label: Label = $HBoxContainer/VBoxContainer/PlayerStaminaLabel
@onready var end_turn_button: Button = %EndTurnButton

func _ready() -> void:
	BattlemapSignals.player_stamina_changed.connect(_on_player_stamina_changed)
	BattlemapSignals.lock_player_input.connect(_on_player_lock_input)
	BattlemapSignals.unlock_player_input.connect(_on_player_unlock_input)


func _on_player_stamina_changed(current_stamina: int):
	player_stamina_label.text = "Stamina: " + str(current_stamina)


func _on_player_lock_input():
	end_turn_button.disabled = true

func _on_player_unlock_input():
	end_turn_button.disabled = false

func _on_end_turn_button_pressed() -> void:
	BattlemapSignals.monster_turn_started.emit()
