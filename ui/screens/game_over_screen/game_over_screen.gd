extends Control
class_name GameOverScreen

@onready var title_label: Label = %TitleLabel
@onready var reward_component: RewardUIComponent = %RewardComponent
@onready var h_box_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer

@export var title_text: String = "You Win"

func _ready() -> void:
	title_label.text = title_text
	reward_component.on_reward_card_picked.connect(_on_reward_card_picked_signal)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	self.get_parent().queue_free()

func add_rewards(card_rewards: Array[CardResource]):
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
	_on_continue_pressed()
