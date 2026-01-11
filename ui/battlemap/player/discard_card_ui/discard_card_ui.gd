extends MarginContainer
class_name DiscardCardUI

@onready var title: Label = $VBoxContainer/Title

## This is what representes the card that has been discarded
## In the future this and the _current_selected_card might be the same
@onready var card: Card = $VBoxContainer/PanelContainer/Card
@onready var discard_button: SoundButton = %DiscardButton

@export var title_string: String = "Select Card to Discard"

## This will be what is actually discarded
var _current_selected_card: Card = null

var _ignore_select_card_list: Array[Card] = []

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	BattlemapSignals.awaiting_for_card_selection.connect(on_awaiting_for_card_selection_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_canceled_input_signal)
	BattlemapSignals.input_received_for_card_selected.connect(select_card)
	discard_button.pressed.connect(_on_button_pressed)

func select_card(
	selected_card: Card
):
	if _ignore_select_card_list.has(selected_card):
		return
	_current_selected_card = selected_card
	var card_resource: CardResourceV2 = selected_card.card_resource
	card.visible = true
	card.discard_button.visible = false
	discard_button.visible = true
	card.card_resource = card_resource
	card.initialize_card()


func _on_button_pressed() -> void:
	BattlemapSignals.card_selected_confirmed.emit(_current_selected_card)
	_ignore_select_card_list.clear()
	_disable_ui()

func on_awaiting_for_card_selection_signal(_ignore_card_list: Array[Card]):
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	if _ignore_card_list:
		_ignore_select_card_list.append_array(_ignore_card_list)

func _on_player_canceled_input_signal():
	BattlemapSignals.card_selected_confirmed.emit(null)
	_disable_ui()

func _disable_ui():
	_current_selected_card = null
	if card and not card.is_queued_for_deletion():
		card.visible = false
	self.visible = false
	self.discard_button.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
