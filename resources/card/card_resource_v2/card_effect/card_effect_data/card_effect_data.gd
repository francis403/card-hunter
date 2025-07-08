extends Resource

## TODO: when the data is being updated in one card,
## it's also being updated in another card of the same type
## Meant for communiction between card effects
class_name CardEffectData

## Tile Selection previous data
var monster_effect_data: MonsterEffectData

var last_selected_tile: Vector2

func get_previous_selected_tile_if_enabled() -> Tile:
	if not last_selected_tile:
		return null
	return BattleController.get_tile(
		last_selected_tile.x,
		last_selected_tile.y,
	)
