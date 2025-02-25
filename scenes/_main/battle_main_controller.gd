extends Node
class_name BattleMainController

@onready var hand: Hand = $Hand

var is_player_turn: bool = true

func _ready() -> void:
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started_signal)
	BattlemapSignals.player_turn_started.connect(_on_player_turn_started_signal)
	_draw_cards_start_of_turn(BattleController.get_player())
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_button_pressed"):
		BattlemapSignals.canceled_player_input.emit()

func _on_player_turn_started_signal():
	print(_on_player_turn_started_signal)
	is_player_turn = true
	
	var player: PlayerPiece = BattleController.get_player()
	# draw up to handsize
	player.draw_til_hand_size()
	
	# populate hand
	_draw_cards_start_of_turn(player)
	#recover stamina
	player.recover_stamina()
	
	BattlemapSignals.unlock_player_input.emit()

func _draw_cards_start_of_turn(player: PlayerPiece):
	player.draw_til_hand_size()
	hand.populate_hand(player.cards_in_hand)

func _on_monster_turn_started_signal():
	is_player_turn = false
	BattlemapSignals.lock_player_input.emit()
	var monster: MonsterPiece = BattleController.get_monster()
	monster.play_monster_turn()
	
