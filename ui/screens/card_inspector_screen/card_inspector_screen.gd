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
var _upgrade_modules: Array[CardModule] = []

# Stores the translation KEY so text restores correctly after a language switch.
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
	# Capture the key stored in the .tscn so we can restore it later.
	change_card_button_original_text = change_card_button.text
	card.card_resource = _initial_displayed_card
	card.initialize_card()
	card_modules_displayer.populate_from_card_resource(_initial_displayed_card)
	change_card_button.pressed_and_sound_played.connect(_on_change_card_button_pressed)
	upgrade_card_button.pressed_and_sound_played.connect(_on_upgrade_card_button_pressed)

	card_modules_container_component.module_pressed.connect(_on_card_module_pressed)
	undo_button.pressed_and_sound_played.connect(_on_undo_button_pressed)
	card_modules_displayer.undoable_action_performed.connect(_on_undoable_action)
	card_modules_displayer.graph_module_closed.connect(_on_graph_module_closed)
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
		# Set translation keys; auto_translate_mode on the buttons handles the rest.
		upgrade_card_button.text = "BTN_SAVE"
		change_card_button.text = "BTN_HIDE_MODULES"
		_is_upgrade_open = true
		undo_button.visible = true
		_update_undo_button_state()
	else:
		if not card_modules_displayer.is_display_module_valid():
			_show_upgrade_error(tr("UI_INVALID_MODULE_CONFIG"))
			return
		_save_card_upgrade()
		_on_card_module_back_button_pressed()

func _show_upgrade_error(message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)

func _save_card_upgrade() -> void:
	var head: CardModule = card_modules_displayer.get_displayed_card_head()
	if not head:
		return

	var old_resource: CardResourceV2 = card.card_resource
	var new_resource: CardResourceV2 = CardResourceV2.new()

	# Copy base card data from old resource
	new_resource.id = "%s_%d" % [old_resource.id, randi()]
	var translated_title: String = tr(old_resource.title)
	new_resource.title = translated_title if translated_title.ends_with("+") else translated_title + "+"
	new_resource.rarity = old_resource.rarity
	new_resource.stamina_cost = old_resource.stamina_cost
	for module in _upgrade_modules:
		new_resource.stamina_cost += module.stamina_cost
	new_resource.tag_array = old_resource.tag_array.duplicate()
	new_resource.card_image = old_resource.card_image
	new_resource.play_conditions.assign(old_resource.play_conditions)
	new_resource.is_forged = true

	
	for _node in card_modules_displayer._node_module_map.values():
		if not _node is CardEffect:
			continue
		new_resource.play_actions.append(_node)
			
	new_resource._generate_card_modules_tree()
	# Append all current special effects (pre-existing + newly added - deleted)
	for effect in card_modules_displayer._special_card_effects:
		new_resource.special_effects.append(effect)

	# Update description to reflect final state
	_update_card_description(new_resource)

	# Swap in deck: remove old card, add new upgraded card.
	# Also clean up the old card from _forged_cards if it was itself a previous upgrade.
	PlayerController.remove_card_from_deck(old_resource.id)
	PlayerController.remove_forged_card(old_resource.id)
	PlayerController.add_card_to_deck(new_resource)
	# Update the displayed card
	card.card_resource = new_resource
	card.initialize_card()

	# Consume modules from player inventory
	for module in _upgrade_modules:
		PlayerController.remove_card_module(module)
	_upgrade_modules.clear()
	change_card_button.text = change_card_button_original_text
	PlayerController.add_forged_card(new_resource)
	File.change_progress()

func _update_card_description(_card_resource: CardResourceV2) -> void:
	var result: String = ""
	for play_action in _card_resource.play_actions:
		result += play_action.title + " "
	result += "\n"
	for special_effect in _card_resource.special_effects:
		result += special_effect.title + " "
	_card_resource.description = result

func _on_card_module_back_button_pressed():
	card_modules_component.visible = false
	card_modules_displayer.enable_module_deletion = false
	card_modules_displayer.enable_module_connection = false
	# Restore translation keys so auto_translate_mode can re-translate on demand.
	upgrade_card_button.text = "BTN_UPGRADE_CARD"
	change_card_button.text = change_card_button_original_text
	_is_upgrade_open = false
	_undo_stack.clear()
	_upgrade_modules.clear()
	undo_button.visible = false

func _on_card_module_pressed(_module: CardModule):
	card_modules_container_component.remove_module(_module.id)
	card_modules_displayer.add_card_module(_module)
	_upgrade_modules.append(_module)

func _on_graph_module_closed(node: BaseCardModuleGraphNode):
	node.get_parent().remove_child(node)
	node.queue_free()

func _on_undoable_action(action_data: Dictionary) -> void:
	_undo_stack.push_back(action_data)
	_update_undo_button_state()
	# When an upgrade module is deleted, return it to container and inventory.
	match action_data.get("type"):
		"REMOVE_MODULE":
			var module: CardModule = action_data.get("module")
			if module and _upgrade_modules.has(module):
				_upgrade_modules.erase(module)
				card_modules_container_component.add_grid_elem(module)
		"REMOVE_SPECIAL_EFFECT":
			var effect: CardModule = action_data.get("effect")
			if effect and _upgrade_modules.has(effect):
				_upgrade_modules.erase(effect)
				card_modules_container_component.add_grid_elem(effect)


func _on_undo_button_pressed() -> void:
	if _undo_stack.is_empty():
		return
	var action: Dictionary = _undo_stack.pop_back()
	card_modules_displayer.undo(action)
	# Mirror the container changes that the original action made.
	match action.get("type"):
		"ADD_MODULE":
			# Undo of an add: module leaves the graph, return it to container + inventory.
			var module: CardModule = action.get("module")
			if module and _upgrade_modules.has(module):
				_upgrade_modules.erase(module)
				card_modules_container_component.add_grid_elem(module)
		"REMOVE_MODULE":
			# Undo of a delete: module re-enters the graph, take it from container + inventory.
			var module: CardModule = action.get("module")
			if module and card_modules_container_component.get_displayed_card_modules().has(module):
				card_modules_container_component.remove_module(module.id)
				_upgrade_modules.append(module)
		"ADD_SPECIAL_EFFECT":
			var effect: CardModule = action.get("effect")
			if effect and _upgrade_modules.has(effect):
				_upgrade_modules.erase(effect)
				card_modules_container_component.add_grid_elem(effect)
		"REMOVE_SPECIAL_EFFECT":
			var effect: CardModule = action.get("effect")
			if effect and card_modules_container_component.get_displayed_card_modules().has(effect):
				card_modules_container_component.remove_module(effect.id)
				_upgrade_modules.append(effect)
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
	if not _forge_card_screen.back_button_pressed.is_connected(_on_forge_screen_back_button_pressed):
		_forge_card_screen.back_button_pressed.connect(_on_forge_screen_back_button_pressed)


func _on_forge_screen_back_button_pressed():
	_on_back_button_pressed()

func _close_forge_screen() -> void:
	if _forge_card_screen:
		_forge_card_screen.queue_free()
		_forge_card_screen = null


func _on_forge_screen_exited() -> void:
	_forge_card_screen = null


func _on_back_button_pressed() -> void:
	queue_free()