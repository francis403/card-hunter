extends Node
class_name BattleSceneRewardsManager

@onready var possible_rewards_container: Node = $PossibleRewards

@export var monsters_container: Node
@export var game_over_screen: GameOverScreen


#func _ready() -> void:
	#BattleSignals.battle_start.connect(_set_rewards_to_reward_screen)

func set_rewards_to_reward_screen():
	var reward_cards: Array[CardResource] = []
	for monster in monsters_container.get_children():
		if not monster is GenericMonster:
			return
		var card_array: Array[CardResource] = monster.get_card_rewards()
		reward_cards.append_array(card_array)
		game_over_screen.add_rewards(card_array)
		for card_resource in card_array:
			_instantiate_card(card_resource)
		#possible_rewards.add_child(monster.get_card_rewards())

func _instantiate_card(card_resource: CardResource):
	if not card_resource:
		return
	var card_instance: Card = Constants.card_scene.instantiate()
	card_instance.card_can_be_discarded = false
	card_instance.card_can_hover = false
	card_instance.card_resource = card_resource
	possible_rewards_container.add_child(card_instance)
	card_instance.initialize_card()
