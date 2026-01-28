extends Control
class_name GameOverScreen

signal reward_picked(card: Card)
signal left_button_pressed
signal right_button_pressed

@onready var title_label: Label = %TitleLabel
@onready var reward_component: RewardUIComponent = %RewardComponent
@onready var bottom_h_container: HBoxContainer = %BottomHContainer
@onready var continue_button: SoundButton = %ContinueButton
@onready var exit_button: SoundButton = %ExitButton

@export_group("General Screen configuration")
@export var title_text_key: String = "UI_YOU_WIN"
@export var reward_component_title_key: String = "UI_CHOOSE_REWARD"
@export var continue_as_soon_as_rewards_picked: bool = false
@export var max_number_of_picks: int = 1

@export_group("On Reward Card Picked configuration")
@export var override_default_on_reward_card_picked: bool = false

@export_group("Game Over Screen Button Configuration")
@export var left_button_text_key: String = "BTN_CONTINUE"
@export var override_left_button: bool = false

@export var show_left_button: bool = true
@export var right_button_text_key: String = "BTN_EXIT"
@export var override_right_button: bool = false
@export var show_right_button: bool = true

var current_number_of_picks: int = 0

func _ready() -> void:
	current_number_of_picks = 0
	title_label.text = tr(self.title_text_key)
	continue_button.text = tr(self.left_button_text_key)
	exit_button.text = tr(self.right_button_text_key)
	_setup_reward_component()
	if not self.show_left_button:
		continue_button.visible = false
	if not self.show_right_button:
		exit_button.visible = false
	
func update_reward_component_title(_reward_component_title_key: String):
	self.reward_component_title_key = _reward_component_title_key
	reward_component.title_label.text = tr(reward_component_title_key)
	
func _setup_reward_component():
	reward_component.title_label.text = tr(reward_component_title_key)
	reward_component.override_default_on_reward_card_picked = self.override_default_on_reward_card_picked
	reward_component.on_reward_card_picked.connect(_on_reward_card_picked_signal)

func _on_exit_pressed() -> void:
	right_button_pressed.emit()
	if self.override_right_button:
		return
	get_tree().quit()

func _on_continue_pressed() -> void:
	left_button_pressed.emit()
	if self.override_left_button:
		return
	get_tree().paused = false
	self.get_parent().queue_free()

func add_rewards(card_rewards: Array[CardResourceV2]):
	reward_component.add_reward_cards(card_rewards)

func _on_reward_card_picked_signal(card: Card):
	current_number_of_picks += 1
	reward_picked.emit(card)
	if self.continue_as_soon_as_rewards_picked and\
		current_number_of_picks >= max_number_of_picks:
		_on_continue_pressed()
		return
	
	
