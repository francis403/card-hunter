extends WorldNodeScreen

class_name TreasureWorldNodeScreen

@onready var treasure_texture_rect: TextureRect = $Treasure
@onready var reward_screen: GameOverScreen = $RewardScreen

var picked_rewards: Dictionary = {}

@export var treasure_world_node_resource: TreasureWorldNode = null

func _ready() -> void:
	if self._world_node_scene and self._world_node_scene is TreasureWorldNode and not treasure_world_node_resource:
		treasure_world_node_resource = _world_node_scene
	_set_up_reward_screen()
	reward_screen.reward_picked.connect(_on_reward_picked_signal)

func _set_up_reward_screen():
	if not reward_screen:
		return
	var _reward_contents: Array[CardResourceV2] = []
	for reward in treasure_world_node_resource.get_world_node_rewards():
		_reward_contents.append(reward)
	reward_screen.add_rewards(_reward_contents)
	reward_screen.left_button_pressed.connect(_on_reward_screen_left_button_pressed_signal)
	reward_screen.max_number_of_picks = treasure_world_node_resource.number_of_choices
	var title: String = "Choose up to " + str(reward_screen.max_number_of_picks) + " rewards"
	reward_screen.update_reward_component_title(title)

func _add_rewards():
	var _reward_contents: Array[CardResourceV2] = []
	if treasure_world_node_resource._specify_treasure_content and treasure_world_node_resource.treasure_content:
		_reward_contents.append_array(treasure_world_node_resource.treasure_content)
	else:
		for i in range(0, self.number_of_rewards):
			var _random_possible_reward: CardResourceV2 = treasure_world_node_resource.possible_treasure_content.pick_random()
			_reward_contents.append(_random_possible_reward)
	reward_screen.add_rewards(_reward_contents)

func _on_treasure_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		reward_screen.visible = true

func _on_reward_picked_signal(card: Card):
	var card_id: int = card.get_instance_id()
	if picked_rewards.has(card_id):
		picked_rewards.erase(card_id)
		card.undisable_card()
		return
	if picked_rewards.size() >= treasure_world_node_resource.number_of_choices:
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
