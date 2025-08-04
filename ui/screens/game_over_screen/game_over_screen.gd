extends Control
class_name GameOverScreen

signal reward_picked(card: Card)
signal left_button_pressed
signal right_button_pressed

@onready var title_label: Label = %TitleLabel
@onready var reward_component: RewardUIComponent = %RewardComponent
@onready var h_box_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer
@onready var continue_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Continue
@onready var exit_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Exit

@export_group("General Screen configuration")
@export var title_text: String = "You Win"
@export var reward_component_title: String = "Choose 1 reward"
@export var continue_as_soon_as_rewards_picked: bool = false
@export var max_number_of_picks: int = 1

@export_group("On Reward Card Picked configuration")
@export var override_default_on_reward_card_picked: bool = false

@export_group("Game Over Screen Button Configuration")
@export var left_button_text: String = "Continue"
@export var override_left_button: bool = false
		
@export var show_left_button: bool = true
@export var right_button_text: String = "Exit"
@export var override_right_button: bool = false
@export var show_right_button: bool = true

var current_number_of_picks: int = 0

func _ready() -> void:
	current_number_of_picks = 0
	title_label.text = self.title_text
	continue_button.text = self.left_button_text
	exit_button.text = self.right_button_text
	_setup_reward_component()
	if not self.show_left_button:
		continue_button.visible = false
	if not self.show_right_button:
		exit_button.visible = false
	
func _setup_reward_component():
	reward_component.title_label.text = reward_component_title
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

func prep_loss_screen():
	title_text = "You Lose"
	title_label.text = title_text
	reward_component.visible = false
	h_box_container.visible = true

func prep_win_screen():
	title_text = "You Win"
	title_label.text = title_text
	reward_component.visible = true
	h_box_container.visible = false

func _on_reward_card_picked_signal(card: Card):
	current_number_of_picks += 1
	reward_picked.emit(card)
	if self.continue_as_soon_as_rewards_picked and\
		current_number_of_picks >= max_number_of_picks:
		_on_continue_pressed()
		return
	
	
