extends Control
class_name CardInspectorScreen

@export var _debug_mode: bool = false

@onready var card: Card = %Card
@onready var change_card_button: SoundButton = %ChangeCardButton
@onready var upgrade_card_button: SoundButton = %UpgradeCard
@onready var card_module_back_button: SoundButton = %CardModuleBackButton

@onready var card_modules_component: MarginContainer = %CardModulesComponent
@onready var card_modules_container_component: CardModulesContainerComponent = %CardModulesContainerComponent
@onready var card_modules_displayer: CardModuleDisplayer = $PanelContainer/VBoxContainer/CardModulesDisplayer

var _deck_visualizer: DeckVisualizer

func _ready() -> void:
	if self._debug_mode:
		card_modules_container_component.add_grim_elems(
			CardModuleController.get_card_modules()
		)
	change_card_button.pressed_and_sound_played.connect(_on_change_card_button_pressed)
	upgrade_card_button.pressed_and_sound_played.connect(_on_upgrade_card_button_pressed)
	card_module_back_button.pressed_and_sound_played.connect(_on_card_module_back_button_pressed)
	card_modules_container_component.module_pressed.connect(_on_card_module_pressed)

func _on_change_card_button_pressed() -> void:
	if _deck_visualizer:
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

	_close_deck_visualizer()


func _on_deck_visualizer_closed() -> void:
	_deck_visualizer = null

func _close_deck_visualizer() -> void:
	if _deck_visualizer:
		_deck_visualizer.queue_free()
		_deck_visualizer = null
		

func _on_upgrade_card_button_pressed():
	card_modules_component.visible = true 
	card_modules_displayer.enable_module_deletion = true

func _on_card_module_back_button_pressed():
	card_modules_component.visible = false
	card_modules_displayer.enable_module_deletion = false

func _on_card_module_pressed(_module: CardModule):
	card_modules_displayer.add_card_module(_module)
