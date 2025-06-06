extends CardEffectWithUserInput

## TODO: It might be better to just create a third resource called TileEffectResource
class_name TileEffectCardEffect

@export var tile_effect_resource: TileEffectResource

func card_effect():
	if target_tile == null:
		return
	if not tile_effect_resource:
		return
	var tile_effect_controller: BaseTileEffectController = init_tile_effect_controller()
	target_tile.add_tile_effect_v2(
		tile_effect_controller
	)

func init_tile_effect_controller() -> BaseTileEffectController:
	var result: BaseTileEffectController = tile_effect_resource.tile_effect_controller.instantiate()
	result.tile_effect_resource = tile_effect_resource
	return result
