extends CardEffect

## Same as RemovePowerCardEffect but required TargetInput before
class_name RemovePowerCardEffectV2

@export var remove_all_negative_effects: bool = false
@export var remove_all_positive_effects: bool = false
@export var remove_specific_status_effects: Array[String] = []

## TODO: do way of targeting monster
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
	if self.remove_all_negative_effects:
		_piece.remove_all_power_effects()
	elif not remove_specific_status_effects.is_empty():
		for status_effect_id in remove_specific_status_effects:
			_piece.remove_power_effect(status_effect_id)
	_response.set_ok()
	return _response
