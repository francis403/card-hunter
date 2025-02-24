extends Node

var battlemap: Battlemap

# TODO: is an array with the piece turn better? 
var is_player_turn: bool = true

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)

func end_button_pressed():
	is_player_turn = not is_player_turn
	if is_player_turn:
		BattlemapSignals.unlock_player_input.emit()
		var player: PlayerPiece = get_player()
		player._stamina += player._stamina_recover
		BattlemapSignals.player_stamina_changed.emit(player._stamina)
	else:
		BattlemapSignals.lock_player_input.emit()
		#start monster turn

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func get_player() -> PlayerPiece:
	return battlemap.player

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)
