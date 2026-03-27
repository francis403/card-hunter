extends CardEffect

## Same as StatusChange but requires tile input beforehand
class_name StatusChangeCardEffectV2

@export var status_modifier_config: StatusModifierConfig

func play_card_effect() -> CardEffectResponse:
	var _response: CardEffectResponse = CardEffectResponse.new()
	_response.set_failure()
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
	if not _piece:
		return _response
	status_modifier_config.apply_status_change(_piece)
	_response.set_ok()
	return _response
