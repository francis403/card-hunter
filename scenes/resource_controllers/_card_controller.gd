extends Node
class_name CardController

var battlemap: Battlemap

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map


func _get_piece(card_resource: CardResource):
	if card_resource.target == Constants.TargetType.SELF:
		return battlemap.player
	return battlemap.monster


func play_card_action(card_resource: CardResource):
	pass
	
func highlight_tiles(piece: Piece, card_resource: CardResource):
	if card_resource.area_type == Constants.AreaType.RADIUS:
		battlemap.highligh_tiles_radius(
			piece,
			card_resource.max_distance
		)
	elif card_resource.area_type == Constants.AreaType.CROSS:
		battlemap.highligh_tiles_cross(
			piece,
			card_resource.max_distance
		)
	elif card_resource.area_type == Constants.AreaType.SPECIFIC:
		print("TODO: specific movement")
	elif card_resource.area_type == Constants.AreaType.SHOTGUN:
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
