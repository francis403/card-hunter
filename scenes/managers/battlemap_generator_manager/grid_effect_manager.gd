extends Node
class_name GridEffectManager

const SPIDERWEB_TILE_EFFECT = preload("res://scenes/game_objects/battlemap/tile_effects/spiderweb/spiderweb_tile_effect.tscn")

func _ready() -> void:
	BattlemapSignals.add_effect_to_tile.connect(_on_add_effect_to_tile_signal)
	BattlemapSignals.add_effect_type_to_tile.connect(_on_add_effect_type_to_tile_signal)


func _on_add_effect_to_tile_signal(tile_effect: TileEffect, tile: Tile):
	tile.add_tile_effect(tile_effect)

func _on_add_effect_type_to_tile_signal(
	tile_effect: Constants.TileEffectTypes,
	tile: Tile
):
	var result: TileEffect = null
	if tile_effect == Constants.TileEffectTypes.SPIDER_WEB:
		result = SPIDERWEB_TILE_EFFECT.instantiate()
	if result:
		tile.add_tile_effect(result)
