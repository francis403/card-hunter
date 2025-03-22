extends Control
class_name Hand

@onready var h_box_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	_clean_preview()
	BattlemapSignals.awaiting_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_canceled_input_signal)
	BattlemapSignals.player_input_received.connect(_on_input_received_signal)
	BattlemapSignals.lock_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.unlock_player_input.connect(_on_input_received_signal)
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discared_from_hand_signal)

## TODO: need to either push map up or make input go through cards
func _on_input_awaiting_signal():
	h_box_container.modulate.a = .33
	h_box_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _on_input_received_signal():
	h_box_container.modulate.a = 1
	h_box_container.mouse_filter = Control.MOUSE_FILTER_PASS
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	self.process_mode = Node.PROCESS_MODE_INHERIT

func _on_player_canceled_input_signal():
	self.process_mode = Node.PROCESS_MODE_INHERIT
	BattlemapSignals.tile_picked_in_battlemap.emit(null)

func _clean_preview():
	for node in h_box_container.get_children():
		node.queue_free()

func populate_hand(new_cards: Array[CardResource]):
	for card_resource in new_cards:
		_instantiate_card(card_resource)

func _instantiate_card(card_resource: CardResource):
	if not card_resource:
		return
	var card_instance: Card = Constants.card_scene.instantiate()
	h_box_container.add_child(card_instance)
	card_instance.card_resource = card_resource
	card_instance.initialize_card()
	
func _on_card_discared_from_hand_signal(index: int):
	pass
