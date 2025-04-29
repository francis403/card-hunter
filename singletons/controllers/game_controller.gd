extends Node

var GIANT_BAT_BATTLE_TEST_SCENE = load("res://scenes/battle_scenes/giant_bat_test_scene/giant_bat_battle_test_scene.tscn")

## days till the boss
var days_till_attack: int = 5
var is_showing_battle_scene: bool = false

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

func _process_settings_screen():
	ScreenUtils.open_settings_screen(get_parent())
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func decrease_days_till_next_attack():
	days_till_attack -= 1
	if days_till_attack <= 0:
		PlayerController.current_world_node = null
		ScreenUtils.open_event_screen(
			get_parent(),
			_prep_boss_battle()
		)
		self.process_mode = Node.PROCESS_MODE_ALWAYS

## TODO: generate better boss battles
## TODO: need to add some event_resource or something
func _prep_boss_battle() -> EventScreen:
	var result: EventScreen = EventScreen.new()
	result.title_text = "Suddently Shadows"
	result.description_text = "After completing your last quest, you suddenlty notice the sun is out.\n" + \
		"Suddently, a giant Bat appears out of nowhere."
	result.accept_button_text = "To the Hunt" 
	result.accept_button_scene = GIANT_BAT_BATTLE_TEST_SCENE
	return result
	
func _prep_thank_you_event() -> EventScreen:
	var result: EventScreen = EventScreen.new()
	result.title_text = "Many thanks"
	result.description_text = "Thank you for playing my game.\n It's still in a very rough phase but it means a lot to me.\n" 
	result.accept_button_text = "Close the game now" 
	result.accept_button_scene = null
	return result
	
