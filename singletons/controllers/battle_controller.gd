extends Node
# TODO: maybe this can be a battlemap_position_controller instead

var battlemap: Battlemap

var player_position: Vector2
var monster_position: Vector2

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)


func _on_battlemap_generated_signal(battlemap: Battlemap):
	self.battlemap = battlemap
