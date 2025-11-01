extends Node
class_name GridEffectManager

#func _ready() -> void:
	#BattlemapSignals.add_effect_to_tile.connect(_on_add_effect_to_tile_signal)
	#BattlemapSignals.add_effect_type_to_tile.connect(_on_add_effect_type_to_tile_signal)


func _on_add_effect_to_tile_signal(tile_effect: TileEffect, tile: Tile):
	if tile:
		tile.add_tile_effect(tile_effect)
