extends Node
class_name CardController

var battlemap: Battlemap

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map


func get_piece(
	card_resource: CardResource,
	card_category: CardCategory
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
	card_category: CardCategory
) -> Constants.AreaType:
	if card_category.area_type == Constants.AreaType.INHERIT:
		return card_resource.default_area_type
	return card_category.area_type


func play_card_action(
	card_resource: CardResource,
	card_categories: CardCategoryDictionary = null
):
	print(play_card_action)
	if not battlemap:
		battlemap = BattleController.battlemap
	
	var stamina_cost = card_resource.stamina_cost
	var player: PlayerPiece = BattleController.get_player()
	player._stamina -= stamina_cost
	if player._stamina < 0:
		# cancel player card
		BattlemapSignals.canceled_player_input.emit()
	else:
		BattlemapSignals.player_stamina_changed.emit(player._stamina)
		
	# TODO: at any point if the card is canceled I need to return the stamina
	
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
		
		
func distance_between_tiles(tile1: Tile, tile2: Tile) -> int:
	var x1 = tile1._x_position
	var x2 = tile2._x_position
	var y1 = tile1._y_position
	var y2 = tile2._y_position
	return round(
		pow(
			pow((x2 - x1), 2) + pow((y2 - y1), 2),
			0.5
		)
	)
