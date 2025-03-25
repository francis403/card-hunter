extends Node

var battlemap: Battlemap

## TODO: remove some stuff from GameController and put it here
func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	
func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func get_player() -> PlayerPiece:
	return battlemap.player
	
func get_monster() -> MonsterPiece:
	return battlemap.monsters[0]

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)
