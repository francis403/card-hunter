extends Control
class_name Hand

@onready var h_box_container: HBoxContainer = $HBoxContainer

@export var draw_pile_marker: Marker2D
@export var discard_pile_marker: Marker2D

var has_drawn_hand_before: bool = false

func _ready() -> void:
	_clean_preview()
	BattlemapSignals.awaiting_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_canceled_input_signal)
	BattlemapSignals.player_input_received.connect(_on_input_received_signal)
	BattlemapSignals.lock_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.unlock_player_input.connect(_on_input_received_signal)
	BattlemapSignals.card_discarded_from_hand.connect(_on_card_discared_from_hand_signal)
	BattlemapSignals.card_discarded_from_hand_reverted.connect(_on_card_discared_from_hand_reverted_signal)
	BattlemapSignals.player_initiated_card_discard.connect(_on_player_initiated_card_discard_signal)

## TODO: need to either push map up or make input go through cards
func _on_input_awaiting_signal():
	h_box_container.modulate.a = .33
	h_box_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h_box_container.set_process_input(false)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.process_mode = Node.PROCESS_MODE_DISABLED
	self.set_process_input(false)
	h_box_container.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])

func _on_input_received_signal():
	h_box_container.modulate.a = 1
	h_box_container.mouse_filter = Control.MOUSE_FILTER_PASS
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	self.process_mode = Node.PROCESS_MODE_INHERIT
	self.set_process_input(true)
	h_box_container.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_PASS])

func _on_player_canceled_input_signal():
	h_box_container.modulate.a = 1
	self.process_mode = Node.PROCESS_MODE_INHERIT
	BattlemapSignals.tile_picked_in_battlemap.emit(null)

func _clean_preview():
	for node in h_box_container.get_children():
		node.queue_free()

## TODO: don't love the way I'm doing the animation
func populate_hand(new_cards: Array[CardResourceV2]):
	var new_instantiated_cards: Array[Card] = []
	for card_resource in new_cards:
		var new_card: Card = _instantiate_card(card_resource)
		new_instantiated_cards.append(new_card)
	if new_instantiated_cards.size() <= 0:
		return
	await h_box_container.sort_children
	if not has_drawn_hand_before:
		has_drawn_hand_before = true
		await h_box_container.sort_children
	for child in new_instantiated_cards:
		var tween = _play_draw_card_animation(child)
		if tween:
			await tween.finished


## TODO: Draw card animation could be done here
func _instantiate_card(card_resource: CardResourceV2) -> Card:
	if not card_resource:
		return
	var card_instance: Card = Constants.card_scene.instantiate()
	h_box_container.add_child(card_instance)
	card_instance.modulate.a = 0.0
	card_instance.card_resource = card_resource
	card_instance.initialize_card()
	return card_instance
	
	
func _play_draw_card_animation(card: Card) -> Tween:
	if not draw_pile_marker || not card:
		return null
	var final_card_position: Vector2 = card.global_position
	var tween = create_tween()
	#tween.parallel()
	#card.visible = true
	tween.tween_property(card, "modulate:a", 1.0, 0)
	tween.tween_property(card, "global_position", draw_pile_marker.global_position, 0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "global_position", final_card_position, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#tween.parallel()
	#tween.tween_property(card, "scale", Vector2(0, 0), 0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#tween.tween_property(card, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return tween
	
func _on_player_initiated_card_discard_signal(card: Card):
	var tween: Tween = _play_discard_card_animation(card, 0.2)
	if tween:
		await tween.finished
	card.queue_free()
	BattlemapSignals.discard_card_animation_finished.emit(true)
	
func _play_discard_card_animation(
	card: Card,
	duration: float = 0.4
) -> Tween:
	if not discard_pile_marker || not card:
		return null
	var tween = create_tween()
	tween.set_parallel(true)
	var target_position = discard_pile_marker.global_position
	target_position.x -= card.size.x / 2  
	target_position.y -= card.size.y / 2

	tween.tween_property(card, "global_position", target_position, duration)
	tween.tween_property(card, "scale", Vector2(0.5, 0.5), duration)
	tween.tween_property(card, "rotation_degrees", randf_range(-15, 15), duration)
	tween.tween_property(card, "modulate:a", 0.8, duration)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	#tween.parallel()
	#tween.tween_property(card, "modulate:a", 1.0, 0)
	#tween.parallel().tween_property(card, "scale", Vector2(1, 1), 0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(card, "global_position", initial_card_position, 0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(card, "scale", Vector2(0.3, 0.3), 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(card, "global_position", discard_pile_marker.global_position, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween
	
func _on_card_discared_from_hand_signal(_index: int):
	pass

## TODO: Play some sort of animation
func _on_card_discared_from_hand_reverted_signal(card_resource: CardResourceV2):
	print(_on_card_discared_from_hand_reverted_signal)
	var card_instance: Card = self._instantiate_card(card_resource)
	card_instance.modulate.a = 1.0

func _on_h_box_container_sort_children() -> void:
	pass
