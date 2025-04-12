extends BattleGenericScene
class_name SpiderWebTestScene

const BOW_DECK: PlayerDeck = preload("res://resources/player_deck/decks/generic_deck/bow_deck.tres")

func _ready() -> void:
	super._ready()
	BattlemapSignals.add_effect_type_to_tile.emit(
		Constants.TileEffectTypes.SPIDER_WEB,
		MovementUtils.get_left_tile(player._tile)
	)
	PlayerController.replace_deck(BOW_DECK)
