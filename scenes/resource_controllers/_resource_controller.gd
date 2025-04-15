extends Node
class_name ResourceController

func get_piece(
	card_resource: CardResource,
	card_category: EventCategory
):
	var target_type = get_target_type(card_resource, card_category)
	return _get_piece(target_type)

func get_target_type(
	card_resource: CardResource,
	card_category: EventCategory
) -> Constants.TargetType:
	if card_category.target == Constants.TargetType.INHERIT:
		return card_resource.default_target
	return card_category.target

func _get_piece(
	target_type: Constants.TargetType
):
	var battlemap: Battlemap = BattleController.battlemap
	if target_type == Constants.TargetType.SELF || target_type == Constants.TargetType.PLAYER || target_type == Constants.TargetType.INHERIT:
		return battlemap.player
	return battlemap.monsters[0]

func get_area_type(
	card_resource: CardResource,
	config_area_type: Constants.AreaType
) -> Constants.AreaType:
	if config_area_type == Constants.AreaType.INHERIT:
		return card_resource.default_area_type
	return config_area_type

func highlight_tiles(
	piece: Piece,
	config: TileHighlightConfig
):
	BattlemapSignals.highlight_tiles.emit(piece._tile, config)

func get_card_tile_highlight_config(
	event_category: EventCategory
) -> TileHighlightConfig:
	return event_category.configuration if event_category.configuration else TileHighlightConfig.new()
