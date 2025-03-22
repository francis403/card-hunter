extends Node
class_name BattleGenericScene

const deck_visualizer_scene = preload("res://ui/deck/deck_visualizer/deck_visualizer.tscn")

@onready var hand: Hand = $Hand
@onready var battlemap: Battlemap = $Battlemap
@onready var ui_nodes: Control = $UINodes

@export var player: PlayerCharacter

var is_player_turn: bool = true

func _ready() -> void:
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started_signal)
	BattlemapSignals.player_turn_started.connect(_on_player_turn_started_signal)
	
	# deck signals
	BattlemapSignals.show_draw_pile_deck.connect(_on_show_draw_pile_deck_signal)
	BattlemapSignals.show_discard_pile_deck.connect(_on_show_discard_pile_deck_signal)

	_draw_cards_start_of_turn(battlemap.player)
	BattleSignals.battle_start.emit()
	

## TODO: if left button is pressed and we are awaiting user input
##		 but we didn't click a tile cancel
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		BattlemapSignals.canceled_player_input.emit()
	elif event.is_action_pressed("left_click"):
		## TODO: check if we are currently awaiting player input
		## TODO: check what ws clicked
		pass
	

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
