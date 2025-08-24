extends MarginContainer
class_name PlayerStatsUi


## TODO: I probably have to put this above the monster (maybe only when it's hovered above)
@onready var monster_hp_progress_bar: ProgressBar = %MonsterHP
@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var player_health_label: Label = %PlayerHealthLabel
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
@onready var player_stamina_label: Label = %PlayerStaminaLabel
@onready var end_turn_button: Button = %EndTurnButton

@export var _critical_health_range: float = 0.3

var _critical_health_effect_tween: Tween

func _ready() -> void:
	BattlemapSignals.player_stamina_changed.connect(_on_player_stamina_changed)
	BattlemapSignals.player_health_changed.connect(_on_player_health_changed)
	BattlemapSignals.lock_player_input.connect(_on_player_lock_input)
	BattlemapSignals.unlock_player_input.connect(_on_player_unlock_input)
	BattlemapSignals.monster_hp_changed.connect(_on_monster_health_changed)
	_initialize_player_stats()

func _on_player_stamina_changed(current_stamina: int):
	# Animate the change
	var tween = create_tween()
	tween.tween_property(stamina_progress_bar, "value", current_stamina, 0.2)
	# Brief highlight effect
	var highlight_tween = create_tween()
	highlight_tween.tween_property(stamina_progress_bar, "modulate", Color(1.2, 1.2, 1.5, 1), 0.1)
	highlight_tween.tween_property(stamina_progress_bar, "modulate", Color.WHITE, 0.2)
	player_stamina_label.text = str(current_stamina) + "/" + str(50)

func _on_player_health_changed(current_health: int):
	player_health_label.text = str(current_health) + "/" + str(100)
	health_progress_bar.value = current_health
	var percentage: float = current_health/100
	if percentage < _critical_health_range:
		_add_critical_health_effect()
	elif _critical_health_effect_tween and _critical_health_effect_tween.is_running():
		_critical_health_effect_tween.kill()
		
func _add_critical_health_effect():
	if _critical_health_effect_tween and _critical_health_effect_tween.is_running():
		return
	_critical_health_effect_tween = create_tween()
	_critical_health_effect_tween.set_loops()
	_critical_health_effect_tween.tween_property(health_progress_bar, "modulate:a", 0.5, 0.5)
	_critical_health_effect_tween.tween_property(health_progress_bar, "modulate:a", 1.0, 0.5)


func _on_player_lock_input():
	end_turn_button.disabled = true

func _on_player_unlock_input():
	end_turn_button.disabled = false

func _on_end_turn_button_pressed() -> void:
	BattlemapSignals.monster_turn_started.emit()

func _on_monster_health_changed(new_hp: int, max_hp: int):
	var progress_bar_value: float = float (new_hp) / float(max_hp)
	monster_hp_progress_bar.value = progress_bar_value

func _initialize_player_stats():
	player_health_label.text = "HP: " + str(PlayerController.current_player_health)
