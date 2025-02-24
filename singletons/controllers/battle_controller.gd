extends Node

var battlemap: Battlemap

# TODO: is an array with the piece turn better? 
var is_player_turn: bool = true

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)


func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func get_player() -> PlayerPiece:
	return battlemap.player

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)
