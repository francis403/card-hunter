extends Control
class_name MainWorldScreen

@onready var world_nodes: MarginContainer = $WorldNodes
@onready var boss_timer_label: Label = %BossTimerLabel
@onready var deck_ui: DeckUI = %DeckUI
@onready var forge_button: ImageButton = %ForgeButton
@onready var world_generator_manager: WorldGeneratorManager = $WorldGeneratorManager
@onready var player_menu: PlayerMenu = %PlayerMenu
@onready var world_background_generator: WorldBackgroundGenerator = $WorldBackgroundGenerator
@onready var village_node_marker: Marker2D = $VillageNodeMarker

func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	BattleSignals.battle_complete.connect(_on_battle_won_signal)
	BattlemapSignals.world_node_screen_completed.connect(_on_world_node_screen_completed_signal)
	GameController.days_till_attack_modified.connect(_on_days_till_attack_modified_signal)
	GameController.world_boss_monster_encountered.connect(_on_world_boss_monster_encountered_signal)
	GameController.debug_mode_toggled.connect(_on_debug_mode_toggled)
	forge_button.on_button_pressed.connect(_on_forge_button_pressed)
	_clean_preview()
	boss_timer_label.text = "Days till next attack: " + str(GameController.days_till_attack)
	# Setup grass exclusions after a frame to ensure all nodes are ready
	call_deferred("_setup_world_background_exclusion_zone")
	

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
	
func _on_debug_mode_toggled(is_debug_mode_on: bool) -> void:
	player_menu.visible = is_debug_mode_on

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

func _setup_world_background_exclusion_zone():
	if not (world_background_generator and village_node_marker):
		return
	var exclusion_zones: Array[Vector2] = [village_node_marker.position]
	
	# Add world nodes to exclusion zones
	for child in world_nodes.get_children():
		if child.has_method("get_global_position"):
			exclusion_zones.append(child.global_position)
		elif child.has_method("get_position"):
			exclusion_zones.append(child.position)
	world_background_generator.set_exclusion_zones(exclusion_zones)

func _on_forge_button_pressed():
	var scene: ForgeCardScreen = Constants.forge_card_screen_scene.instantiate()
	get_tree().root.add_child(scene)
