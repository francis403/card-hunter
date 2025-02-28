extends Node
class_name ResourceController

var battlemap: Battlemap

func get_piece(
	card_resource: CardResource,
	card_category: EventCategory
):
	if card_category.target == Constants.TargetType.INHERIT:
		return _get_piece(card_resource.default_target)
	return _get_piece(card_category.target)

func _get_piece(
	target_type: Constants.TargetType
):
	if target_type == Constants.TargetType.SELF || target_type == Constants.TargetType.INHERIT:
		return battlemap.player
	return battlemap.monster

func get_area_type(
	card_resource: CardResource,
	card_category: EventCategory
) -> Constants.AreaType:
	if card_category.area_type == Constants.AreaType.INHERIT:
		return card_resource.default_area_type
	return card_category.area_type

func highlight_tiles(
	piece: Piece,
	area_type: Constants.AreaType,
	range: int,
	show_attack_tile: bool = false
):
	BattlemapSignals.highlight_tiles.emit(piece._tile, range, area_type)
