extends Control
class_name CardInspectorScreen

@export var _debug_mode: bool = false

@onready var card: Card = %Card
@onready var change_card_button: SoundButton = %ChangeCardButton
@onready var card_modules_displayer: CardModuleDisplayer = $PanelContainer/VBoxContainer/CardModulesDisplayer

var _deck_visualizer: DeckVisualizer

func _ready() -> void:
	change_card_button.pressed_and_sound_played.connect(_on_change_card_button_pressed)


func _on_change_card_button_pressed() -> void:
	if _deck_visualizer:
		return

	_deck_visualizer = Refs.deck_visualizer_scene.instantiate()
	_deck_visualizer.deck = PlayerController.get_deck()._deck
	if self._debug_mode:
		_deck_visualizer.deck = CardResourcesController.get_cards().filter(
			func(_card: CardResourceV2): return _card.use_new_card_module_system
		)
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
