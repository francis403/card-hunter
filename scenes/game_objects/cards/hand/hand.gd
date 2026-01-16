extends MarginContainer
class_name Hand

const CARD_WIDTH: int = 170

@onready var hand_container: Control = $HandContainer
@onready var cards_being_discarded_container: Control = $CardsBeingDiscardedContainer

@export var draw_pile_marker: Marker2D
@export var discard_pile_marker: Marker2D

@export_group("Hand Appearance")
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var max_rotation_degrees: float = 5
@export var x_sep: int = -10
@export var y_min: int = 0
@export var y_max: int = -15

var has_drawn_hand_before: bool = false

func _ready() -> void:
	_clean_preview()
	BattlemapSignals.awaiting_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_canceled_input_signal)
	BattlemapSignals.player_input_received.connect(_on_input_received_signal)
	BattlemapSignals.lock_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.unlock_player_input.connect(_on_input_received_signal)
	BattlemapSignals.card_discarded_from_hand_reverted.connect(_on_card_discared_from_hand_reverted_signal)

func _on_input_awaiting_signal():
	hand_container.modulate.a = .33
	hand_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hand_container.set_process_input(false)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.process_mode = Node.PROCESS_MODE_DISABLED
	self.set_process_input(false)
	hand_container.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])

func _on_input_received_signal():
	hand_container.modulate.a = 1
	hand_container.mouse_filter = Control.MOUSE_FILTER_PASS
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	self.process_mode = Node.PROCESS_MODE_INHERIT
	self.set_process_input(true)
	hand_container.propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_PASS])

func _on_player_canceled_input_signal():
	hand_container.modulate.a = 1
	self.process_mode = Node.PROCESS_MODE_INHERIT
	BattlemapSignals.tile_picked_in_battlemap.emit(null)

func _clean_preview():
	for node in hand_container.get_children():
		node.queue_free()

## TODO: don't love the way I'm doing the animation
func populate_hand(new_cards: Array[CardResourceV2]):
	var new_instantiated_cards: Array[Card] = []
	for card_resource in new_cards:
		var new_card: Card = _instantiate_card(card_resource)
		new_instantiated_cards.append(new_card)
	if new_instantiated_cards.size() <= 0:
		return
	update_hand_positions()
	#await h_box_container.sort_children
	if not has_drawn_hand_before:
		has_drawn_hand_before = true
		#await h_box_container.sort_children
	for child in new_instantiated_cards:
		var tween = _play_draw_card_animation(child)
		if tween:
			await tween.finished

func discard_card(
	_card: Card
) -> void:
	_card.reparent(cards_being_discarded_container)
	update_hand_positions()
	await self.play_discard_card_animation(_card)
	if _card and not _card.is_queued_for_deletion():
		_card.queue_free()
	else:
		push_warning("Issue when freeing card!")

## Play discard card animation for card in hand
func play_discard_card_animation(card: Card):
	var tween: Tween = _play_discard_card_animation(card)
	if tween:
		await tween.finished
	BattlemapSignals.discard_card_animation_finished.emit(true)

func _instantiate_card(card_resource: CardResourceV2) -> Card:
	if not card_resource:
		return
	var card_instance: Card = Constants.card_scene.instantiate()
	hand_container.add_child(card_instance)
	card_instance.modulate.a = 0.0
	card_instance.card_resource = card_resource
	card_instance.initialize_card()
	return card_instance
	
func _play_draw_card_animation(card: Card) -> Tween:
	if not draw_pile_marker || not card:
		return null
		
	var final_position = card.global_position
	var final_rotation: float = card.rotation_degrees
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Start from draw pile with small scale
	card.global_position = draw_pile_marker.global_position
	card.scale = AnimationConstants.CARD_DRAW_START_SCALE
	card.rotation_degrees = 0
	card.modulate.a = 0.0
	
	# Animate appearance
	tween.tween_property(card, "modulate:a", 1.0, AnimationConstants.CARD_DRAW_FADE_DURATION)
	
	# Scale up with bounce effect
	tween.tween_property(card, "scale", AnimationConstants.CARD_DRAW_BOUNCE_SCALE, AnimationConstants.CARD_DRAW_SCALE_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", AnimationConstants.CARD_DRAW_FINAL_SCALE, AnimationConstants.CARD_DRAW_SCALE_SETTLE_DURATION)\
		.set_delay(AnimationConstants.CARD_DRAW_SCALE_DURATION)
	
	# Move to final position with curve
	tween.tween_property(card, "global_position", final_position, AnimationConstants.CARD_DRAW_DURATION)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Subtle rotation during movement
	tween.tween_property(card, "rotation_degrees", randf_range(-AnimationConstants.CARD_DRAW_ROTATION_RANGE, AnimationConstants.CARD_DRAW_ROTATION_RANGE), AnimationConstants.CARD_DRAW_ROTATION_DURATION)
	tween.tween_property(card, "rotation_degrees", final_rotation, AnimationConstants.CARD_DRAW_ROTATION_DURATION).set_delay(AnimationConstants.CARD_DRAW_ROTATION_DURATION)
	
	return tween
	
func _play_discard_card_animation(
	card: Card,
	duration: float = AnimationConstants.CARD_DISCARD_DURATION
) -> Tween:
	if not discard_pile_marker || not card:
		return null
		
	var tween = create_tween()
	tween.set_parallel(true)
	
	var target_position = discard_pile_marker.global_position
	# Center the card on the discard pile marker
	target_position.x -= card.size.x / 2  
	target_position.y -= card.size.y / 2
	# Add random offset for natural pile stacking
	target_position += Vector2(randf_range(-5, 5), randf_range(-5, 5))
	
	# Create curved arc movement path
	var start_position = card.global_position
	var mid_point = start_position.lerp(target_position, 0.5)
	mid_point.y -= AnimationConstants.CARD_DISCARD_ARC_HEIGHT  # Arc height
	
	# Two-phase movement for natural arc
	# Phase 1: Rise to peak of arc
	tween.tween_property(card, "global_position", mid_point, AnimationConstants.CARD_DISCARD_ARC_DURATION_PHASE1)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Phase 2: Fall to discard pile
	tween.tween_property(card, "global_position", target_position, AnimationConstants.CARD_DISCARD_ARC_DURATION_PHASE2)\
		.set_delay(AnimationConstants.CARD_DISCARD_ARC_DURATION_PHASE1)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	
	# Scale down smoothly
	tween.tween_property(card, "scale", AnimationConstants.CARD_DISCARD_END_SCALE, duration)
	
	# Natural rotation with more variety
	var rotation_amount = randf_range(AnimationConstants.CARD_DISCARD_ROTATION_MIN, AnimationConstants.CARD_DISCARD_ROTATION_MAX)
	if randf() > 0.5:
		rotation_amount *= -1  # Random direction
	tween.tween_property(card, "rotation_degrees", rotation_amount, duration)
	
	# Fade out near the end for smooth disappearance
	tween.tween_property(card, "modulate:a", 0.0, AnimationConstants.CARD_DISCARD_FADE_DURATION)\
		.set_delay(duration - AnimationConstants.CARD_DISCARD_FADE_DURATION)
	
	return tween

## TODO: Play some sort of animation
func _on_card_discared_from_hand_reverted_signal(card_resource: CardResourceV2):
	print(_on_card_discared_from_hand_reverted_signal)
	var card_instance: Card = self._instantiate_card(card_resource)
	card_instance.modulate.a = 1.0

func update_hand_positions() -> void:
	var _hand_size: int = hand_container.get_child_count()
	var _total_cards_size: float = Card.SIZE.x * _hand_size + x_sep * (_hand_size - 1)
	var _final_sep_x = x_sep
	
	if _total_cards_size > self.size.x:
		_final_sep_x = (size.x - Card.SIZE.x * _hand_size) / (_hand_size - 1)
		_total_cards_size = self.size.x
		
	var _offset: float = (self.size.x - _total_cards_size) / 2
	
	for i in _hand_size:
		var _card: Card = hand_container.get_child(i)
		var _y_multipler: float = hand_curve.sample(1.0 / (_hand_size-1) * i)
		var _rotation_multipler: float = rotation_curve.sample(1.0 / (_hand_size-1) * i)
		
		if _hand_size == 1:
			_y_multipler = 0.0
			_rotation_multipler = 0.0
			
		var _final_x: float = _offset + Card.SIZE.x * i + _final_sep_x * i
		var _final_y: float = y_min + y_max * _y_multipler
		_card.position = Vector2(_final_x, _final_y)
		_card.rotation_degrees = max_rotation_degrees * _rotation_multipler
