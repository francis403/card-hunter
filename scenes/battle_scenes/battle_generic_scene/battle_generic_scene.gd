extends Node
class_name BattleGenericScene

const deck_visualizer_scene = preload("res://ui/deck/deck_visualizer/deck_visualizer.tscn")

@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var hand: Hand = $Hand
@onready var battlemap: Battlemap = $Battlemap
@onready var ui_nodes: Control = $UINodes
@onready var battle_scene_rewards_manager: BattleSceneRewardsManager = $BattleSceneRewardsManager

## holds all monsters in the battle scene
@onready var monsters_node: Node = $monsters

@export var player: PlayerCharacter

## Defines the monsters in the battle scene
@export var monsters: Array[Piece] = []

var is_player_turn: bool = true
var awaiting_player_input: bool = false

var _number_of_monsters_defeated: int = 0

func _ready() -> void:
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started_signal)
	BattlemapSignals.player_turn_started.connect(_on_player_turn_started_signal)
	
	# deck signals
	BattlemapSignals.show_draw_pile_deck.connect(_on_show_draw_pile_deck_signal)
	BattlemapSignals.show_discard_pile_deck.connect(_on_show_discard_pile_deck_signal)

	# Player signals
	BattlemapSignals.awaiting_player_input.connect(_on_awaiting_player_input_signal)
	BattlemapSignals.player_input_received.connect(_on_player_input_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_input_signal)
	# Monsters
	BattlemapSignals.monster_died.connect(_on_monster_died_signal)
	BattlemapSignals.player_died.connect(_on_battle_lost_signal)
	BattleSignals.battle_won.connect(_on_battle_won_signal)

	_draw_cards_start_of_turn(battlemap.player)
	_prep_battle_arena_monsters()
	battle_scene_rewards_manager.set_rewards_to_reward_screen()
	BattleSignals.battle_start.emit()

func _on_player_turn_started_signal():
	is_player_turn = true
	var player: PlayerPiece = BattleController.get_player()
	_draw_cards_start_of_turn(player)
	player.recover_stamina()
	BattlemapSignals.unlock_player_input.emit()

func _draw_cards_start_of_turn(player: PlayerPiece):
	var new_cards: Array[CardResource] = player.draw_til_hand_size()
	hand.populate_hand(new_cards)
	if new_cards.size() > 0:
		BattlemapSignals.draw_pile_updated.emit(player.draw_pile)
	
func _prep_battle_arena_monsters():
	if monsters.size() > 0:
		battlemap.monsters = []
		battlemap.monsters.append_array(monsters)
		for monster in monsters:
			monsters_node.add_child(monster)
		battlemap.update_monsters()
	
func _on_monster_turn_started_signal():
	is_player_turn = false
	BattlemapSignals.lock_player_input.emit()
	for monster in battlemap.monsters:
		monster.play_monster_turn()
	
func _on_show_draw_pile_deck_signal():
	var deck_visualizer_instance: DeckVisualizer = deck_visualizer_scene.instantiate()
	player.draw_pile.shuffle()
	deck_visualizer_instance.deck = player.draw_pile
	ui_nodes.add_child(deck_visualizer_instance)
	
	
func _on_show_discard_pile_deck_signal():
	var deck_visualizer_instance: DeckVisualizer = deck_visualizer_scene.instantiate()
	deck_visualizer_instance.deck = player.discard_pile
	ui_nodes.add_child(deck_visualizer_instance)
	
func _on_awaiting_player_input_signal():
	awaiting_player_input = true
	
func _on_player_input_signal():
	awaiting_player_input = false
	
func _on_monster_died_signal():
	_number_of_monsters_defeated += 1
	if _number_of_monsters_defeated >= battlemap.get_total_amount_of_monsters():
		PlayerController.current_player_health = player._health
		BattleSignals.battle_won.emit()

func _on_battle_lost_signal():
	#game_over_screen.title_label.text = "You Lost"
	game_over_screen.prep_loss_screen()
	_show_game_over_screen()

func _on_battle_won_signal():
	if PlayerController.current_world_node:
		PlayerController.current_world_node.clear_monsters()
	BattlemapSignals.node_completed.emit(File.progress.current_world_node_id)
	game_over_screen.prep_win_screen()
	_show_game_over_screen()
	
## TODO: add possible rewards
func _show_game_over_screen():
	game_over_screen.visible = true
	get_tree().paused = true
	game_over_screen.process_mode = Node.PROCESS_MODE_ALWAYS
