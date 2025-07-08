extends Control

## TODO: will need to have some config that can be changed during the game to have multiple choices
class_name TreasureWorldNodeScreen


@onready var treasure_texture_rect: TextureRect = $Treasure
@onready var reward_screen: GameOverScreen = $RewardScreen

@export_group("Treasure Rewards")
## add specific contents to the rewards
@export var treasure_content: Array[CardResourceV2] = []
@export var number_of_rewards: int = 3
@export var number_of_choices: int = 2

func _ready() -> void:
	_set_up_reward_screen()

func _set_up_reward_screen():
	if not reward_screen:
		return
	_add_rewards()

func _add_rewards():
	if treasure_content and not treasure_content.is_empty():
		reward_screen.add_rewards(treasure_content)
		return
	

func _on_treasure_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		reward_screen.visible = true
