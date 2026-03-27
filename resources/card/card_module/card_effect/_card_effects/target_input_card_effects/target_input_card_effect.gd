extends CardEffect

## CardEffect that simply triggers the player's input for a tile.
class_name TargetInputCardEffect

@export_group("Tile Highlight Configuration")
@export var tile_highlight_config: TileHighlightConfig
## Should we just return the player tile, or should the tile be selected
@export_enum("SELF", "OTHER") var area_input_type: String = "SELF"


func _get_my_node_scene_path() -> String:
	return "res://resources/card/card_module/card_effect/_card_effects/target_input_card_effects/target_input_card_effect.gd"


func to_dictionary() -> Dictionary:
	var result: Dictionary = super.to_dictionary()
	result["area_input_type"] = area_input_type
	if tile_highlight_config:
		result["tile_highlight_config"] = tile_highlight_config.to_dictionary()
	return result


func from_dictionary(dictionary: Dictionary) -> void:
	super.from_dictionary(dictionary)
	if dictionary.has("area_input_type"):
		area_input_type = dictionary["area_input_type"]
	if dictionary.has("tile_highlight_config"):
		tile_highlight_config = TileHighlightConfig.new()
		tile_highlight_config.from_dictionary(dictionary["tile_highlight_config"])


func play_card_effect() -> CardEffectResponse:
	var response: CardEffectResponse = CardEffectResponse.new()
	GeneralUtils.debug_log(
		"-- TargetInputCardEffect with area %s" % [area_input_type],
		GameController.debug_mode_enabled
	)
	var _selected_tile: Tile = await _get_selected_tile()
	if not _selected_tile:
		response.set_failure()
		return response
	response.tile_selected = _selected_tile
	response.set_ok()
	return response

func _get_selected_tile() -> Tile:
	match area_input_type:
		"SELF":
			if BattleController.get_player():
				return BattleController.get_player()._tile
		"OTHER":
			return await _get_user_input(
				tile_highlight_config,
				BattleController.get_player()
			)
	return null

func _get_user_input(
	config: TileHighlightConfig,
	_piece: Piece = null
) -> Tile:
	
	GeneralUtils.debug_log(
		"--- _get_user_input for _piece %s" % [Piece],
		GameController.debug_mode_enabled
	)
	
	if not _piece:
		return null
	# freeze hand
	BattlemapSignals.awaiting_player_input.emit()

	config.origin_tile = _piece._tile
	#config.target_tile = target_tile
	# show possible squares and await input
	BattlemapSignals.highlight_tiles.emit(
		_piece._tile,
		config
	)
	
	var _target_tile = await BattlemapSignals.tile_picked_in_battlemap
	BattlemapSignals.player_input_received.emit()
	return _target_tile
