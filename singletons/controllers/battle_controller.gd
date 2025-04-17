extends Node

var battlemap: Battlemap

var turn_counter: int = 0

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	
func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		BattlemapSignals.canceled_player_input.emit()

func get_player() -> PlayerPiece:
	return battlemap.player
	
func get_monster() -> MonsterPiece:
	return battlemap.monsters[0]

func get_tile(x: int, y: int) -> Tile:
	return battlemap.get_tile(x, y)

## TODO: how can we do this knowing what we already know
func get_random_tile(center_tile: Tile, config: TileHighlightConfig) -> Tile:
	return null
