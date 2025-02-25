extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer

var card_scene: PackedScene = preload("res://scenes/game_objects/cards/card/card.tscn")

func _ready() -> void:
	_clean_preview()
	BattlemapSignals.awaiting_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.canceled_player_input.connect(_on_input_received_signal)
	BattlemapSignals.player_input_received.connect(_on_input_received_signal)
	BattlemapSignals.lock_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.unlock_player_input.connect(_on_input_received_signal)

func _on_input_awaiting_signal():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _on_input_received_signal():
	self.process_mode = Node.PROCESS_MODE_INHERIT

func _clean_preview():
	for node in h_box_container.get_children():
		node.queue_free()

func populate_hand(cards_in_hand: Array[CardResource]):
	for card_resource in cards_in_hand:
		_instantiate_card(card_resource)
		
func _instantiate_card(card_resource: CardResource):
	var card_instance: Card = card_scene.instantiate()
	card_instance.card_resource = card_resource
	h_box_container.add_child(card_instance)
