extends Node

signal days_till_attack_modified(days: int)
signal world_boss_monster_encountered
signal debug_mode_toggled(is_debug_mode: bool)

const BATTLE_GENERIC_SCENE = preload("res://scenes/battle_scenes/battle_generic_scene/battle_generic_scene.tscn")

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
var number_of_villages_saved: int = 0

func _ready() -> void:
	BattleSignals.boss_battle_complete.connect(_on_boss_battle_complete_signal)
	BattleSignals.game_complete.connect(_on_game_complete_signal)

func _on_boss_battle_complete_signal():
	self.days_till_attack = 5
	self.number_of_villages_saved += 1
	if number_of_villages_saved < 2:
		ScreenUtils.open_event_screen(
			get_parent(),
			_prep_new_world_event()
		)
		self.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		_on_game_complete_signal()

func _on_game_complete_signal():
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
	
## TODO: we should have this events in resources
func _prep_new_world_event() -> EventScreen:
	var result: EventScreen = EventScreen.new()
	result.title_text = "New Village to save"
	result.description_text = "You've managed to saved one village, but there's still one more village that needs your help.\n" 
	result.accept_button_text = "Save the village!" 
	result.override_accept_button_function = true
	result.on_accept_button_pressed_signal.connect(_on_new_world_event_accept_button_pressed)
	result.accept_button_scene = null
	return result

func _on_new_world_event_accept_button_pressed(_event_screen: EventScreen):
	_event_screen.close_screen()
	BattleSignals.world_generation_triggered.emit()

func _prep_thank_you_event() -> EventScreen:
	var result: EventScreen = EventScreen.new()
	result.title_text = "Many thanks"
	result.description_text = "Thank you for playing my game.\n It's still in a very rough phase but it means a lot to me.\n" 
	result.accept_button_text = "Close the game now" 
	result.accept_button_scene = null
	return result
	
func generate_battle_scene(
	_monster: GenericMonster,
	_is_boss_battle: bool = false,
	_world_node: GenericWorldNode = null
) -> BattleGenericScene:
	var battle_scene: BattleGenericScene = BATTLE_GENERIC_SCENE.instantiate()
	battle_scene.is_boss_battle = _is_boss_battle
	battle_scene.monsters.clear()
	battle_scene.monsters.append(_monster)
	battle_scene.set_world_node(_world_node)
	return battle_scene
