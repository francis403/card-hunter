extends BattleGenericScene
class_name SpiderWebTestScene


func _ready() -> void:
	super._ready()
	BattlemapSignals.add_effect_type_to_tile.emit(
		Constants.TileEffectTypes.SPIDER_WEB,
		MovementUtils.get_left_tile(player._tile)
	)
