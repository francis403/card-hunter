extends GenericMonster
class_name SpiderMonster

const SPIDERWEB_TILE_EFFECT = preload("res://scenes/game_objects/battlemap/tile_effects/spiderweb/spiderweb_tile_effect.tscn")

func _ready() -> void:
	super._ready()
	print(_ready)
	BattleSignals.battle_start.connect(_on_battle_start_signal)
	
	
func _on_battle_start_signal():
	print(_on_battle_start_signal)
	print("tile: ", self._tile)
	var left_tile: Tile = MovementUtils.get_left_tile(self._tile)
	if left_tile:
		add_spider_web(left_tile)

func add_spider_web(tile: Tile):
	var spider_web: TileEffect = SPIDERWEB_TILE_EFFECT.instantiate()
	tile.add_tile_effect(spider_web)
	
