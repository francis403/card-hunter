extends Node
class_name BattleMainController

var is_player_turn: bool = true

func _ready() -> void:
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started_signal)
	BattlemapSignals.player_turn_started.connect(_on_player_turn_started_signal)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_button_pressed"):
		BattlemapSignals.canceled_player_input.emit()

func _on_player_turn_started_signal():
	is_player_turn = true
	
	var player: PlayerPiece = BattleController.get_player()
	# draw up to handsize
	player.draw_til_hand_size()
	
	#recover stamina
	player._stamina += player._stamina_recover
	BattlemapSignals.player_stamina_changed.emit(player._stamina)
	
	BattlemapSignals.unlock_player_input.emit()

func _on_monster_turn_started_signal():
	is_player_turn = false
	BattlemapSignals.lock_player_input.emit()
	var monster: MonsterPiece = BattleController.get_monster()
	monster.play_monster_turn()
	
