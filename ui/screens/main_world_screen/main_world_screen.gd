extends Control
class_name MainWorldScreen

@onready var world_nodes: MarginContainer = $WorldNodes
@onready var boss_timer_label: Label = %BossTimerLabel
@onready var deck_ui: DeckUI = $DeckUI
@onready var world_generator_manager: WorldGeneratorManager = $WorldGeneratorManager

func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	BattleSignals.battle_complete.connect(_on_battle_won_signal)
	BattlemapSignals.world_node_screen_completed.connect(_on_world_node_screen_completed_signal)
	GameController.days_till_attack_modified.connect(_on_days_till_attack_modified_signal)
	GameController.world_boss_monster_encountered.connect(_on_world_boss_monster_encountered_signal)
	_clean_preview()
	boss_timer_label.text = "Days till next attack: " + str(GameController.days_till_attack)
	

func _clean_preview():
	for child in world_nodes.get_children():
		child.queue_free()

func _update_days_till_attack(_days: int):
	boss_timer_label.text = "Days till next attack: " + str(_days)
	deck_ui._update_deck_label()

func _on_battle_start_signal():
	world_nodes.process_mode = Node.PROCESS_MODE_DISABLED

func _on_node_complete_signal():
	pass

func _on_days_till_attack_modified_signal(days: int):
	_update_days_till_attack(days)
	
func _on_world_boss_monster_encountered_signal():
	PlayerController.current_world_node = null
	ScreenUtils.open_event_screen(
		get_parent(),
		_prep_boss_battle()
	)

## TODO: generate better boss battles
## TODO: need to add some event_resource or something
func _prep_boss_battle() -> EventScreen:
	var result: EventScreen = EventScreen.new()
	result.title_text = "Suddently Shadows"
	result.description_text = "After completing your last quest, you suddenlty notice the sun is out.\n" + \
		"Suddently, a giant Bat appears out of nowhere."
	result.accept_button_text = "To the Hunt" 
	result.accept_button_scene = world_generator_manager.get_random_world_boss_scene()
	return result

func _on_battle_won_signal():
	world_nodes.process_mode = Node.PROCESS_MODE_ALWAYS
	GameController.decrease_days_till_next_attack()

func _on_world_node_screen_completed_signal(_advance_day: bool):
	GameController.decrease_days_till_next_attack()
