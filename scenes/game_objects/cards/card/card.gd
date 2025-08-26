extends MarginContainer
class_name Card

signal card_picked(card: Card)
signal card_played
signal card_discarded_by_effect

const DISABLED_CARD_COLOR = Color(0.502, 0.502, 0.502, 0.463)
const NORMAL_CARD_COLOR = Color(1, 1, 1)

@export var card_resource: CardResourceV2
@export var card_can_hover: bool = true
@export var card_can_be_discarded: bool = true
@export var is_disabled: bool = false
@export var _card_can_be_played: bool = true

@onready var card_title: Label = %CardTitle
@onready var card_description: Label = %CardDescription
@onready var stamina_cost_label: Label = %StaminaCostLabel
@onready var discard_button: Button = %DiscardButton
@onready var special_effect_controller: Node = $SpecialEffectController
@onready var full_card_container: MarginContainer = $FullCardContainer
@onready var back_ground_texture_rect: TextureRect = $BackGroundTextureRect

var card_can_be_played: bool = true
var _mouse_hovering: bool = false
var _discard_button_mouse_hovering: bool = false

var _is_enabled: bool = true

## TODO: we can probably do a manager here for this
var _is_awaiting_card_selection: bool = false

func _ready() -> void:
	if card_resource:
		initialize_card()
		BattlemapSignals.awaiting_for_card_selection.connect(on_awaiting_for_card_selection_signal)
		BattlemapSignals.card_selected_confirmed.connect(on_card_selection_confirmed_signal)
		BattlemapSignals.canceled_player_input.connect(_revert_played_card)
	self.card_can_be_played = _card_can_be_played

func initialize_card():
	card_title.text = card_resource.title
	card_description.text = card_resource.description
	stamina_cost_label.text = str(card_resource.stamina_cost)
	card_resource.subscribe_to_special_effects(self, special_effect_controller)


func _on_gui_input(event: InputEvent) -> void:
	if _discard_button_mouse_hovering:
		return
	if _mouse_hovering and event.is_action_pressed("left_click"):
		_card_clicked()

func _is_awaiting_player_input() -> bool:
	return self.modulate.a <= 0.5

func _card_clicked():
	if _is_awaiting_card_selection:
		_add_selected_card()
	else:
		_play_card()
	card_picked.emit(self)

func _add_selected_card():
	BattlemapSignals.input_received_for_card_selected.emit(self)

## TODO: I can just call discard_card here
func _play_card():
	if not card_can_be_played:
		return
	BattleController._current_card_being_played = self
	if card_resource.card_finished_playing.get_connections().size() == 0:
		card_resource.card_finished_playing.connect(_on_card_finished_playing)
	await card_resource.play_card()
	self.card_played.emit()

func _revert_played_card():
	card_resource.revert_all_played_card_effects()
	BattleController._current_card_being_played = null

func _on_card_finished_playing():
	BattleController._current_card_being_played = null
	if card_resource.tag_array.has("one_use"):
		BattlemapSignals.card_removed_from_deck.emit()
		self.queue_free()
	else:
		_discard_card()

func _discard_card() -> bool:
	if not _can_card_be_discarded():
		push_warning(_discard_card, " warning:  card cannot be discarded.")
		return false
	BattlemapSignals.card_discarded_from_hand.emit(self.get_index())
	BattleController.discard_card_from_player(self)
	return true

func _on_mouse_entered() -> void:
	_mouse_hovering = true
	_play_hover_animation()

func _play_hover_animation():
	if not _card_can_hover():
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Lift card up
	tween.tween_property(self, "position:y", AnimationConstants.CARD_HOVER_LIFT, AnimationConstants.CARD_HOVER_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Subtle scale increase
	tween.tween_property(self, "scale", AnimationConstants.CARD_HOVER_SCALE, AnimationConstants.CARD_HOVER_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	# Glow effect
	tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.2, 1.0), AnimationConstants.CARD_HOVER_DURATION)

func _on_mouse_exited() -> void:
	_mouse_hovering = false
	_play_unhover_animation()

func _play_unhover_animation():
	if not _card_can_hover():
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Return to original position
	tween.tween_property(self, "position:y", 0, AnimationConstants.CARD_HOVER_UNHOVER_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	# Return to original scale
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), AnimationConstants.CARD_HOVER_UNHOVER_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	# Remove glow
	tween.tween_property(self, "modulate", Color.WHITE, AnimationConstants.CARD_HOVER_UNHOVER_DURATION)
	
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

func toggle_enabled():
	self._is_enabled = not self._is_enabled
	self.modulate.a = 255 if self._is_enabled else 100

func add_stamina_cost(stamina_cost: int):
	if not card_resource:
		return
	card_resource.stamina_cost += stamina_cost

func toggle_disable_card():
	if self.modulate == DISABLED_CARD_COLOR:
		undisable_card()
	else:
		disable_card()

func disable_card():
	self.modulate = DISABLED_CARD_COLOR
	
func undisable_card():
	self.modulate = NORMAL_CARD_COLOR
