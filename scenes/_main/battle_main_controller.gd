extends Node
class_name BattleMainController

@onready var hand: Hand = $Hand
@onready var battlemap: Battlemap = $Battlemap

var is_player_turn: bool = true

func _ready() -> void:
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started_signal)
	BattlemapSignals.player_turn_started.connect(_on_player_turn_started_signal)
	BattlemapSignals.monster_prepared_move.connect(_on_monster_prepared_move_signal)

	_draw_cards_start_of_turn(BattleController.get_player())	
	BattleSignals.battle_start.emit()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_button_pressed"):
		BattlemapSignals.canceled_player_input.emit()

func _on_player_turn_started_signal():
	is_player_turn = true
	var player: PlayerPiece = BattleController.get_player()
	_draw_cards_start_of_turn(player)
	player.recover_stamina()
	BattlemapSignals.unlock_player_input.emit()
#
func _on_monster_prepared_move_signal(monster_sprite: Sprite2D, move_tile: Tile):	
	if not move_tile:
		return
	battlemap.add_child(monster_sprite)
	battlemap.place_node_in_tile(monster_sprite, move_tile)
	monster_sprite.scale = BattleController.get_monster().scale
	monster_sprite.modulate = Color.WEB_GRAY

func _draw_cards_start_of_turn(player: PlayerPiece):
	var new_cards = player.draw_til_hand_size()
	hand.populate_hand(new_cards)

func _on_monster_turn_started_signal():
	is_player_turn = false
	BattlemapSignals.lock_player_input.emit()
	var monster: MonsterPiece = BattleController.get_monster()
	monster.play_monster_turn()
	
