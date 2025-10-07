extends Node

signal days_till_attack_modified(days: int)
signal world_boss_monster_encountered
signal debug_mode_toggled(is_debug_mode: bool)

var is_showing_battle_scene: bool = false
var debug_mode_enabled: bool = false

## days till the boss
var days_till_attack: int = 5:
	set(value):
		days_till_attack = value
		days_till_attack_modified.emit(days_till_attack)
		if days_till_attack <= 0:
			world_boss_monster_encountered.emit()

var current_player_node_id: String

func _ready() -> void:
	BattleSignals.boss_battle_complete.connect(_on_boss_battle_complete_signal)

func _on_boss_battle_complete_signal():
	ScreenUtils.open_event_screen(
		get_parent(),
		_prep_thank_you_event()
	)
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_button_pressed"):
		_process_settings_screen()
	if event.is_action_pressed("debug_mode_toggle"):
		_toggle_debug_mode()

func _process_settings_screen():
	ScreenUtils.open_settings_screen(get_parent())
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func decrease_days_till_next_attack():
	days_till_attack -= 1

func _toggle_debug_mode():
	debug_mode_enabled = !debug_mode_enabled
	debug_mode_toggled.emit(debug_mode_enabled)
	
func _prep_thank_you_event() -> EventScreen:
	var result: EventScreen = EventScreen.new()
	result.title_text = "Many thanks"
	result.description_text = "Thank you for playing my game.\n It's still in a very rough phase but it means a lot to me.\n" 
	result.accept_button_text = "Close the game now" 
	result.accept_button_scene = null
	return result
	
