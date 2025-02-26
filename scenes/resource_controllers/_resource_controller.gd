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
	range: int
):
	if area_type == Constants.AreaType.RADIUS:
		battlemap.highligh_tiles_radius(
			piece,
			range
		)
	elif area_type == Constants.AreaType.CROSS:
		battlemap.highligh_tiles_cross(
			piece,
			range
		)
	elif area_type == Constants.AreaType.SPECIFIC:
		print("TODO: specific movement")
	elif area_type == Constants.AreaType.SHOTGUN:
		print("TODO: shotgun movement")
