extends WorldNodeScreen

## TODO: will need to have some config that can be changed during the game to have multiple choices
class_name TreasureWorldNodeScreen

@onready var treasure_texture_rect: TextureRect = $Treasure
@onready var reward_screen: GameOverScreen = $RewardScreen

@export_group("Treasure Rewards")
## add specific contents to the rewards
@export var treasure_content: Array[CardResourceV2] = []
@export var number_of_rewards: int = 3
@export var number_of_choices: int = 2

var picked_rewards: Dictionary = {}

func _ready() -> void:
	_set_up_reward_screen()
	reward_screen.reward_picked.connect(_on_reward_picked_signal)

func _set_up_reward_screen():
	if not reward_screen:
		return
	_add_rewards()
	reward_screen.left_button_pressed.connect(_on_reward_screen_left_button_pressed_signal)
	reward_screen.max_number_of_picks = number_of_choices

func _add_rewards():
	if treasure_content and not treasure_content.is_empty():
		reward_screen.add_rewards(treasure_content)
		return

func _on_treasure_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		reward_screen.visible = true

func _on_reward_picked_signal(card: Card):
	var card_id: String = card.card_resource.id
	if picked_rewards.has(card_id):
		picked_rewards.erase(card_id)
		card.undisable_card()
		return
	if picked_rewards.size() >= number_of_choices:
		return
	picked_rewards[card_id] = card
	card.disable_card()

## Maybe show some warning if no cards were picked
func _on_reward_screen_left_button_pressed_signal():
	for key in picked_rewards.keys():
		var _card: Card = picked_rewards[key]
		var card_resource: CardResourceV2 = _card.card_resource
		PlayerController._deck.add_card(card_resource.duplicate())
	self.world_node_screen_completed.emit(true)
	#get_tree().paused = false
	#self.get_parent().queue_free()
