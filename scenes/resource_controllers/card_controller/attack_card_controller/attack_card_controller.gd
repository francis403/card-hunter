extends CardController
class_name AttackCardController

func play_card_action(card_resource: CardResource):
	if not battlemap:
		battlemap = BattleController.battlemap
	var target = _get_piece(card_resource)
	if not target:
		return
	
	var range_of_attack = card_resource.max_distance
	
	# TODO: check if range is close enough to attack
	var player_tile = BattleController.battlemap.player._tile
	var target_tile = target._tile
	
	if distance_between_tiles(player_tile, target_tile) <= range_of_attack:
		target.queue_free()


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
