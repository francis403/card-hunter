extends Node

signal days_till_attack_modified(days: int)
signal world_boss_monster_encountered
signal debug_mode_toggled(is_debug_mode: bool)

const DEFAULT_DAYS_TILL_ATTACK: int = 5

## Expresses the number of bosses to defeat before finding the last boss
const NUMBER_OF_VILLAGES_TO_SAVE: int = 3

var is_showing_battle_scene: bool = false
var debug_mode_enabled: bool = false

## days till the boss
var days_till_attack: int = DEFAULT_DAYS_TILL_ATTACK:
	set(value):
		days_till_attack = value
		days_till_attack_modified.emit(days_till_attack)
		if days_till_attack <= 0:
			world_boss_monster_encountered.emit()

var current_player_node_id: String
var number_of_villages_saved: int = 0

func _ready() -> void:
	BattleSignals.boss_battle_complete.connect(_on_boss_battle_complete_signal)
	BattleSignals.game_complete.connect(complete_game)

func _on_boss_battle_complete_signal():
	File.meta_progress.update_bosses_defeated()
	self.days_till_attack = 5
	self.number_of_villages_saved += 1
	if number_of_villages_saved < NUMBER_OF_VILLAGES_TO_SAVE:
		EventController.show_event(EventController.EventID.NEW_WORLD, get_parent())
		self.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		complete_game()

func complete_game():
	## Update meta_progress
	File.meta_progress.update_games_completed(true)
	File.change_meta_progress()
	EventController.show_event(EventController.EventID.THANK_YOU, get_parent())
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

func generate_battle_scene(
	_monster: GenericMonster,
	_is_boss_battle: bool = false,
	_world_node: GenericWorldNode = null
) -> BattleGenericScene:
	var _hunt_scene: BattleGenericScene =\
		Refs.generic_battle_scene.instantiate().duplicate()
	_hunt_scene.is_boss_battle = _is_boss_battle
	_hunt_scene.monsters.clear()
	var _monster_to_add: GenericMonster = _monster.duplicate()
	_hunt_scene.monsters.append(_monster_to_add)
	_hunt_scene.add_child(_monster_to_add)
	_monster_to_add.owner = _hunt_scene
	if _world_node:
		_hunt_scene.set_world_node(_world_node)
	return _hunt_scene
