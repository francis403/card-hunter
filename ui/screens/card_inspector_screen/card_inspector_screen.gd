extends Control
class_name CardInspectorScreen

@export var _initial_displayed_card: CardResourceV2
@export var _debug_mode: bool = false

@onready var card: Card = %Card
@onready var change_card_button: SoundButton = %ChangeCardButton
@onready var upgrade_card_button: SoundButton = %UpgradeCard
@onready var undo_button: SoundButton = %UndoButton

@onready var card_modules_component: MarginContainer = %CardModulesComponent
@onready var card_modules_container_component: CardModulesContainerComponent = %CardModulesContainerComponent
@onready var card_modules_displayer: CardModuleDisplayer = $PanelContainer/HBoxContainer/TabContainer/InspectTab/CardModulesDisplayer
@onready var tab_container: TabContainer = $PanelContainer/HBoxContainer/TabContainer
@onready var forge_tab: Control = $PanelContainer/HBoxContainer/TabContainer/ForgeTab
@onready var back_button: SoundButton = %BackButton

var _deck_visualizer: DeckVisualizer
var _is_upgrade_open: bool = false
var _undo_stack: Array[Dictionary] = []
var _forge_card_screen: ForgeCardScreen

var change_card_button_original_text: String

func _ready() -> void:
	if self._debug_mode:
		card_modules_container_component.add_grim_elems(
			CardModuleController.get_card_modules()
		)
	else:
		card_modules_container_component.add_grim_elems(
			PlayerController.get_card_modules()
		)
	change_card_button_original_text = change_card_button.text
	card_modules_displayer.populate_from_card_resource(_initial_displayed_card.dup())
	change_card_button.pressed_and_sound_played.connect(_on_change_card_button_pressed)
	upgrade_card_button.pressed_and_sound_played.connect(_on_upgrade_card_button_pressed)

	card_modules_container_component.module_pressed.connect(_on_card_module_pressed)
	undo_button.pressed_and_sound_played.connect(_on_undo_button_pressed)
	card_modules_displayer.undoable_action_performed.connect(_on_undoable_action)
	tab_container.tab_changed.connect(_on_tab_changed)
	back_button.pressed_and_sound_played.connect(_on_back_button_pressed)

func _on_change_card_button_pressed() -> void:
	if _deck_visualizer:
		return
	if _is_upgrade_open:
		_on_card_module_back_button_pressed()
		change_card_button.text = change_card_button_original_text
		return
	_deck_visualizer = Refs.deck_visualizer_scene.instantiate()
	_deck_visualizer.deck = PlayerController.get_deck()._deck
	if self._debug_mode:
		_deck_visualizer.deck = CardResourcesController.get_cards()
	_deck_visualizer.listen_for_card_clicks = true
	_deck_visualizer.on_card_clicked.connect(_on_deck_card_selected)
	_deck_visualizer.on_back_button_clicked.connect(_on_deck_visualizer_closed)
	add_child(_deck_visualizer)


func _on_deck_card_selected(selected_card: Card) -> void:
	if not selected_card or not selected_card.card_resource:
		return

	card.card_resource = selected_card.card_resource
	card.initialize_card()
	card_modules_displayer.populate_from_card_resource(selected_card.card_resource)
	_undo_stack.clear()
	_update_undo_button_state()

	_close_deck_visualizer()


func _on_deck_visualizer_closed() -> void:
	_deck_visualizer = null

func _close_deck_visualizer() -> void:
	if _deck_visualizer:
		_deck_visualizer.queue_free()
		_deck_visualizer = null
		

func _on_upgrade_card_button_pressed():
	if not _is_upgrade_open:
		card_modules_component.visible = true
		card_modules_displayer.enable_module_deletion = true
		card_modules_displayer.enable_module_connection = true
		upgrade_card_button.text = "Save"
		change_card_button.text = "Hide Modules"
		_is_upgrade_open = true
		undo_button.visible = true
		_update_undo_button_state()
	else:
		if not card_modules_displayer.is_display_module_valid():
			print("TODO: Show error on module creation")
			return
		var _new_card_head: CardModule = card_modules_displayer.get_displayed_card_head()
		card.card_resource.start_card_module = _new_card_head
		_undo_stack.clear()

func _on_card_module_back_button_pressed():
	card_modules_component.visible = false
	card_modules_displayer.enable_module_deletion = false
	card_modules_displayer.enable_module_connection = false
	upgrade_card_button.text = "Upgrade Card"
	_is_upgrade_open = false
	_undo_stack.clear()
	undo_button.visible = false

func _on_card_module_pressed(_module: CardModule):
	card_modules_displayer.add_card_module(_module)


func _on_undoable_action(action_data: Dictionary) -> void:
	_undo_stack.push_back(action_data)
	_update_undo_button_state()


func _on_undo_button_pressed() -> void:
	if _undo_stack.is_empty():
		return
	card_modules_displayer.undo(_undo_stack.pop_back())
	_update_undo_button_state()


func _update_undo_button_state() -> void:
	undo_button.disabled = _undo_stack.is_empty()


func _on_tab_changed(tab_index: int) -> void:
	if tab_index == 1:
		_open_forge_screen()
	else:
		_close_forge_screen()


func _open_forge_screen() -> void:
	if _forge_card_screen:
		return
	_forge_card_screen = preload("res://ui/screens/forge_card_screen/forge_card_screen.tscn").instantiate()
	forge_tab.add_child(_forge_card_screen)
	_forge_card_screen.tree_exited.connect(_on_forge_screen_exited)
	_forge_card_screen.get_node("PanelContainer/MarginContainer/VBoxContainer/MarginContainer/BackButton").visible = false
	_forge_card_screen.get_node("PanelContainer/MarginContainer/VBoxContainer/MarginContainer/PageTitle").visible = false


func _close_forge_screen() -> void:
	if _forge_card_screen:
		_forge_card_screen.queue_free()
		_forge_card_screen = null


func _on_forge_screen_exited() -> void:
	_forge_card_screen = null


func _on_back_button_pressed() -> void:
	queue_free()
