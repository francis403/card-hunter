extends Control
class_name PlayerStatsUi

@onready var player_health_label: Label = %PlayerHealthLabel
@onready var player_stamina_label: Label = %PlayerStaminaLabel
@onready var end_turn_button: Button = %EndTurnButton

## TODO: I probably have to put this above the monster (maybe only when it's hovered above)
@onready var monster_hp_progress_bar: ProgressBar = %MonsterHP

func _ready() -> void:
	BattlemapSignals.player_stamina_changed.connect(_on_player_stamina_changed)
	BattlemapSignals.player_health_changed.connect(_on_player_health_changed)
	BattlemapSignals.lock_player_input.connect(_on_player_lock_input)
	BattlemapSignals.unlock_player_input.connect(_on_player_unlock_input)
	BattlemapSignals.monster_hp_changed.connect(_on_monster_health_changed)
	_initialize_player_stats()

func _on_player_stamina_changed(current_stamina: int):
	player_stamina_label.text = "Stamina: " + str(current_stamina)

func _on_player_health_changed(current_health: int):
	player_health_label.text = "HP: " + str(current_health)

func _on_player_lock_input():
	end_turn_button.disabled = true

func _on_player_unlock_input():
	end_turn_button.disabled = false

func _on_end_turn_button_pressed() -> void:
	BattlemapSignals.monster_turn_started.emit()

func _on_monster_health_changed(new_hp: int, max_hp: int):
	var progess_bar_value: float = float (new_hp) / float(max_hp)
	monster_hp_progress_bar.value = progess_bar_value

func _initialize_player_stats():
	player_health_label.text = "HP: " + str(PlayerController.current_player_health)
