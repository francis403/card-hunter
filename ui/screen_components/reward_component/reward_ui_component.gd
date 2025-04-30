extends VBoxContainer
class_name RewardUIComponent

signal on_reward_card_picked

@onready var card_container: HBoxContainer = %CardContainer
@onready var title_label: Label = $Title

@export var title: String = "Choose 1 reward"
@export var hide_if_empty: bool = true

var number_of_reward_cards: int = 0
	
func _ready() -> void:
	_delete_preview()
	_initialize_fields()
	#_hide_if_no_rewards()
	
	
func _delete_preview():
	for preview_item in card_container.get_children():
		preview_item.queue_free()


func _initialize_fields():
	title_label.text = title

func _hide_if_no_rewards():
	if not hide_if_empty:
		return
	if number_of_reward_cards <= 0:
		self.visible = false

func add_reward_cards(reward_cards: Array[CardResource]):
	for reward_card in reward_cards:
		_instantiate_card(reward_card)
		number_of_reward_cards += 1


func _instantiate_card(card_resource: CardResource):
	if not card_resource:
		return
	var card_instance: Card = Constants.card_scene.instantiate()
	card_instance.card_can_be_discarded = false
	card_instance.card_can_hover = false
	card_instance.card_can_be_played = false
	card_instance.card_resource = card_resource
	card_container.add_child(card_instance)
	card_instance.initialize_card()
	card_instance.card_picked.connect(_on_card_picked_signal)

func _on_card_picked_signal(card_resource: CardResource):
	PlayerController._deck.add_card(card_resource.duplicate())
	on_reward_card_picked.emit()
