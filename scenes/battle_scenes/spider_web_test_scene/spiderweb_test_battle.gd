extends BattleGenericScene
class_name SpiderWebTestScene

const SPIDERWEB_TILE_EFFECT = preload("res://scenes/game_objects/battlemap/tile_effects/spiderweb/spiderweb_tile_effect.tscn")

func _ready() -> void:
	super._ready()
	var spider_web_instance = SPIDERWEB_TILE_EFFECT.instantiate()
	#MovementUtils.get_left_tile(player._tile).add_tile_effect_v2(
		#spider_web_instance
	#)
