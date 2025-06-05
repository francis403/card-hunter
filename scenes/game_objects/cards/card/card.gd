extends MarginContainer
class_name Card

signal card_picked(card_resource: CardResourceV2)
signal card_played
signal card_discarded_by_effect

@export var card_resource: CardResourceV2
@export var card_can_hover: bool = true
@export var card_can_be_discarded: bool = true

@onready var card_title: Label = %CardTitle
@onready var card_description: Label = %CardDescription
@onready var stamina_cost_label: Label = %StaminaCostLabel
@onready var discard_button: Button = %DiscardButton
@onready var special_effect_controller: Node = $SpecialEffectController

var card_can_be_played: bool = true
var _mouse_hovering: bool = false
var _discard_button_mouse_hovering: bool = false

## TODO: we can probably do a manager here for this
var _is_awaiting_card_selection: bool = false

func _ready() -> void:
	if card_resource:
		initialize_card()
		print(_ready, ": ", self.card_resource.id)
		BattlemapSignals.awaiting_for_card_selection.connect(on_awaiting_for_card_selection_signal)
		BattlemapSignals.card_selected_confirmed.connect(on_card_selection_confirmed_signal)
		BattlemapSignals.canceled_player_input.connect(_revert_played_card)

func initialize_card():
	card_title.text = card_resource.title
	card_description.text = card_resource.description
	stamina_cost_label.text = str(card_resource.stamina_cost)
	card_resource.subscribe_to_special_effects(self, special_effect_controller)
	
# TODO: this should probably go to the hand_manager
func _input(event: InputEvent) -> void:
	if _discard_button_mouse_hovering:
		return
	if _mouse_hovering and event.is_action_pressed("left_click"):
		_card_clicked()

func _card_clicked():
	if _is_awaiting_card_selection:
		_add_selected_card()
	else:
		_play_card()
	card_picked.emit(self.card_resource)

func _add_selected_card():
	BattlemapSignals.input_received_for_card_selected.emit(self)

func _play_card():
	if not card_can_be_played:
		return
	BattleController._current_card_being_played = self
	if card_resource.card_finished_playing.get_connections().size() == 0:
		card_resource.card_finished_playing.connect(_on_card_finished_playing)
	card_resource.play_card()
	self.card_played.emit()

func _revert_played_card():
	card_resource.revert_all_played_card_effects()
	BattleController._current_card_being_played = null

func _on_card_finished_playing():
	BattleController._current_card_being_played = null
	if card_resource.tag_array.has("one_use"):
		BattlemapSignals.card_removed_from_deck.emit(self.get_index())
		self.queue_free()
	else:
		_discard_card()

func _discard_card() -> bool:
	if not _can_card_be_discarded():
		return false
	BattlemapSignals.card_discarded_from_hand.emit(self.get_index())
	self.queue_free()
	return true

func _on_mouse_entered() -> void:
	_mouse_hovering = true
	if not _card_can_hover():
		return
	var tween = create_tween()
	tween.tween_property(self, "position:y", -50, .4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_mouse_exited() -> void:
	_mouse_hovering = false
	if not _card_can_hover():
		return
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0, .4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
func _card_can_hover() -> bool:
	return card_can_hover && not _is_awaiting_card_selection
	
func _can_card_be_discarded() -> bool:
	return card_can_be_discarded && not _is_awaiting_card_selection
	
## NO longer used
func _on_discard_button_pressed() -> void:
	if not card_can_be_discarded:
		return
	_discard_card()


func _on_discard_button_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		_discard_card()

func _on_discard_button_mouse_exited() -> void:
	_discard_button_mouse_hovering = false

func _on_discard_button_mouse_entered() -> void:
	_discard_button_mouse_hovering = true

## SIGNALS
func on_awaiting_for_card_selection_signal(_ignore_card_list: Array[Card]):
	_is_awaiting_card_selection = true
	
func on_card_selection_confirmed_signal(
	_card: Card
):
	_is_awaiting_card_selection = false
