extends Control
class_name GameOverScreen

@onready var title_label: Label = %TitleLabel
@onready var reward_component: RewardUIComponent = %RewardComponent
@onready var h_box_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer
@onready var continue_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Continue

@export var title_text: String = "You Win"
@export var left_button_text: String = "Continue"
@export var reward_component_title: String = "Choose 1 reward"

@export var max_number_of_picks: int = 1

var current_number_of_picks: int = 0

func _ready() -> void:
	current_number_of_picks = 0
	title_label.text = title_text
	continue_button.text = left_button_text
	reward_component.title_label.text = reward_component_title
	reward_component.on_reward_card_picked.connect(_on_reward_card_picked_signal)
	

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_continue_pressed() -> void:
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

func _on_reward_card_picked_signal():
	current_number_of_picks += 1
	
	if current_number_of_picks >= max_number_of_picks:
		_on_continue_pressed()
		return
	
