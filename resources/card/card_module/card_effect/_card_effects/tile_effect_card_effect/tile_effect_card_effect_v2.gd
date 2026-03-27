extends CardEffect

## Same as TileEffect but requires input before
class_name TileEffectCardEffectV2

@export var tile_effect_resource: TileEffectResource

func play_card_effect() -> CardEffectResponse:
	var _response: CardEffectResponse = CardEffectResponse.new()
	_response.set_failure()
	if not tile_effect_resource:
		push_error("No tile_effect_resource provided")
		return _response
	if not _previous_card_module_resp:
		push_error("Previous card_module response necessary but not provided.")
		return _response
	if not _previous_card_module_resp.tile_selected:
		push_error("Previous card_module response has no selected tile")
		return _response
	var _selected_tile: Tile = _previous_card_module_resp.tile_selected
	var tile_effect_controller: BaseTileEffectController = init_tile_effect_controller()
	_selected_tile.add_tile_effect_v2(
		tile_effect_controller
	)
	_response.set_ok()
	return _response

func init_tile_effect_controller() -> BaseTileEffectController:
	var result: BaseTileEffectController = tile_effect_resource.tile_effect_controller.instantiate()
	result.tile_effect_resource = tile_effect_resource
	return result
