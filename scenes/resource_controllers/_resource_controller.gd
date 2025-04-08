extends Node
class_name ResourceController

var battlemap: Battlemap

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
	if target_type == Constants.TargetType.SELF || target_type == Constants.TargetType.INHERIT:
		return battlemap.player
	return battlemap.monster[0]

func get_area_type(
	card_resource: CardResource,
	card_category: EventCategory
) -> Constants.AreaType:
	if card_category.area_type == Constants.AreaType.INHERIT:
		return card_resource.default_area_type
	return card_category.area_type

func highlight_tiles(
	piece: Piece,
	config: TileHighlightConfig
):
	BattlemapSignals.highlight_tiles.emit(piece._tile, config)
