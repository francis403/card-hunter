extends CardEffect

## Same as power_card_effect but requires TargetInput before
class_name PowerCardEffectV2

@export var power_effect: PowerEffect

func play_card_effect() -> CardEffectResponse:
	var _response: CardEffectResponse = CardEffectResponse.new()
	_response.set_failure()
	if not power_effect:
		push_error("No power_effect set as resource.")
		return _response
	if not _previous_card_module_resp:
		push_error("Previous card_module response necessary but not provided.")
		return _response
	if not _previous_card_module_resp.tile_selected:
		push_error("Previous card_module response has no selected tile")
		return _response
	var _selected_tile: Tile = _previous_card_module_resp.tile_selected
	if not _selected_tile.piece_in_tile:
		push_warning("Previous card_module response tile has no piece in it!")
		return _response
	var _piece: Piece = _selected_tile.piece_in_tile
	_piece.add_power_effect(
		power_effect.init_base_power_node(_piece)
	)
	_response.set_ok()
	return _response
	
