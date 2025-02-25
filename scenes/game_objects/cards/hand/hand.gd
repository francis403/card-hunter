extends Control
class_name Hand

@onready var h_box_container: HBoxContainer = $HBoxContainer

var card_scene: PackedScene = preload("res://scenes/game_objects/cards/card/card.tscn")

func _ready() -> void:
	_clean_preview()
	BattlemapSignals.awaiting_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.canceled_player_input.connect(_on_input_received_signal)
	BattlemapSignals.player_input_received.connect(_on_input_received_signal)
	BattlemapSignals.lock_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.unlock_player_input.connect(_on_input_received_signal)
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discared_from_hand_signal)

func _on_input_awaiting_signal():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _on_input_received_signal():
	self.process_mode = Node.PROCESS_MODE_INHERIT

func _clean_preview():
	for node in h_box_container.get_children():
		node.queue_free()

func populate_hand(new_cards: Array[CardResource]):
	for card_resource in new_cards:
		_instantiate_card(card_resource)

func _instantiate_card(card_resource: CardResource):
	if not card_resource:
		print("card resource is null")
		return
	var card_instance: Card = card_scene.instantiate()
	h_box_container.add_child(card_instance)
	card_instance.card_resource = card_resource
	card_instance.initialize_card()
	
func _on_card_discared_from_hand_signal(index: int):
	pass
