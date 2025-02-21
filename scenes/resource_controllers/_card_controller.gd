extends Node
class_name CardController

var battlemap: Battlemap

func _ready() -> void:
	BattlemapSignals.battlemap_generated.connect(_on_battlemap_generated_signal)
	battlemap = BattleController.battlemap
#Question, do we need this to be extending node? 
#	Maybe a script would be enough, we don't need an entire packed scene

func _on_battlemap_generated_signal(map: Battlemap):
	print(_on_battlemap_generated_signal)
	self.battlemap = map


func _get_piece(card_resource: CardResource):
	if card_resource.affects == card_resource.AFFECTS_ENUM.SELF:
		return battlemap.player
	return battlemap.monster


func play_card_action(card_resource: CardResource):
	pass
	
func highlight_tiles(piece: Piece, card_resource: CardResource):
	if card_resource.area_type == CardResource.AREA_TYPE.RADIUS:
		battlemap.highligh_tiles_radius(
			piece,
			card_resource.max_distance
		)
	elif card_resource.area_type == CardResource.AREA_TYPE.CROSS:
		battlemap.highligh_tiles_cross(
			piece,
			card_resource.max_distance
		)
	elif card_resource.area_type == CardResource.AREA_TYPE.SPECIFIC:
		print("TODO: specific movement")
