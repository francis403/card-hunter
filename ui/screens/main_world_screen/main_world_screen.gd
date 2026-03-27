extends Control
class_name MainWorldScreen

const BOSS_EVENTS: Array[EventConfig] = [
	preload("res://resources/configuration/events/event_config/_event_configs/boss_encounter_giant_bat_event.tres"),
	preload("res://resources/configuration/events/event_config/_event_configs/boss_encounter_giant_worm_event.tres"),
	preload("res://resources/configuration/events/event_config/_event_configs/boss_encounter_grasshopper_event.tres"),
]

var possible_boss_events: Array[EventConfig] = []

@export var world_genator_config_generator: WorldGeneratorConfigManager

@onready var world_nodes: MarginContainer = $WorldNodes
@onready var boss_timer_label: Label = %BossTimerLabel
@onready var deck_ui: DeckUI = %DeckUI
@onready var forge_button: ImageButton = %ForgeButton
@onready var world_nodes_table_component: WorldNodesTableComponent = $WorldNodesTableComponent
@onready var player_menu: PlayerMenu = %PlayerMenu
@onready var world_background_generator: WorldBackgroundGenerator = $WorldBackgroundGenerator
@onready var village_node_marker: Marker2D = $VillageNodeMarker
@onready var tutorial_banner: TutorialBanner = $TutorialBannerLayer/TutorialBanner

func _ready() -> void:
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	BattleSignals.battle_complete.connect(_on_battle_won_signal)
	BattleSignals.world_generation_triggered.connect(_on_world_generation_triggered)
	BattlemapSignals.world_node_screen_completed.connect(_on_world_node_screen_completed_signal)
	GameController.days_till_attack_modified.connect(_on_days_till_attack_modified_signal)
	GameController.world_boss_monster_encountered.connect(_on_world_boss_monster_encountered_signal)
	GameController.debug_mode_toggled.connect(_on_debug_mode_toggled)
	forge_button.on_button_pressed.connect(_on_forge_button_pressed)
	_clean_preview()
	boss_timer_label.text = LocalizationController.tr_format("UI_DAYS_TILL_ATTACK", [GameController.days_till_attack])
	# Setup grass exclusions after a frame to ensure all nodes are ready
	world_nodes_table_component.instantiate_world()
	world_nodes_table_component.world_generated.connect(_on_world_generated)
	## Set boss list
	possible_boss_events = BOSS_EVENTS.duplicate()
	possible_boss_events.shuffle()
	## Show tutorial message
	if TutorialController.should_show_tutorial:
		EventController.show_event(EventController.EventID.TUTORIAL_WELCOME, self)
	## Show world tutorial if battle tutorial completed but world tutorial not done
	elif TutorialController.is_tutorial_completed() and not TutorialController.is_world_tutorial_completed():
		call_deferred("_start_world_tutorial")
	call_deferred("_setup_world_background_exclusion_zone")
	
func _clean_preview():
	for child in world_nodes.get_children():
		child.queue_free()

func _update_days_till_attack(_days: int):
	boss_timer_label.text = LocalizationController.tr_format("UI_DAYS_TILL_ATTACK", [_days])
	deck_ui._update_deck_label()

func _on_battle_start_signal():
	world_nodes.process_mode = Node.PROCESS_MODE_DISABLED

func _on_days_till_attack_modified_signal(days: int):
	_update_days_till_attack(days)
	
func _on_world_boss_monster_encountered_signal():
	PlayerController.current_world_node = null
	var boss_event = possible_boss_events.pop_front()
	EventController.show_event_via_resource(
		boss_event,
		get_parent()
	)

func _on_debug_mode_toggled(is_debug_mode_on: bool) -> void:
	player_menu.visible = is_debug_mode_on


func _on_battle_won_signal():
	world_nodes.process_mode = Node.PROCESS_MODE_ALWAYS
	GameController.decrease_days_till_next_attack()

func _on_world_generation_triggered():
	world_nodes.process_mode = Node.PROCESS_MODE_INHERIT
	if not world_genator_config_generator:
		return
	world_nodes_table_component.generate_new_world(
		world_genator_config_generator.generate_config(),
		false
	)

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

func _on_world_generated():
	self._setup_world_background_exclusion_zone()

func _on_forge_button_pressed():
	var scene: Node = Refs.editor_card_screen_scene.instantiate()
	get_tree().root.add_child(scene)

func _start_world_tutorial() -> void:
	tutorial_banner.tutorial_completed.connect(_on_world_tutorial_completed)
	world_nodes.process_mode = Node.PROCESS_MODE_DISABLED
	tutorial_banner.start_tutorial()
	

func _on_world_tutorial_completed() -> void:
	TutorialController.mark_world_tutorial_completed()
	world_nodes.process_mode = Node.PROCESS_MODE_INHERIT
