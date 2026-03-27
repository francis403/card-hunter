extends Node
class_name PiecePositionManager

@export var animation_duration: float = 0.3
@export var animation_easing: Tween.EaseType = Tween.EASE_OUT

var _player: PlayerPiece:
	set(player):
		_player = player

func animate_piece_to_position(piece: Piece, target_position: Vector2):
	if not piece:
		return
	
	var duration = piece.movement_duration if piece.movement_duration > 0 else animation_duration
	var tween: Tween = create_tween()
	
	if not piece.movement_curve:
		tween.set_ease(animation_easing)
		tween.tween_property(piece, "position", target_position, duration)
		return
	var start_position = piece.position
	tween.tween_method(_animate_with_curve.bind(piece, start_position, target_position), 0.0, 1.0, duration)
	

func _animate_with_curve(piece: Piece, start_pos: Vector2, target_pos: Vector2, progress: float):
	if not piece or not piece.movement_curve:
		return
	
	var curve_value = piece.movement_curve.sample(progress)
	piece.position = start_pos.lerp(target_pos, curve_value)

func place_piece(piece: Piece, position: Vector2):
	piece.position = position


func place_piece_in_tile(piece: Piece, tile: Tile, animate: bool = true):
	place_node_in_tile(piece, tile, animate)

## TODO: do Giant monsters need at least 2 speed?
func place_node_in_tile(node: Node2D, tile: Tile, animate: bool = true):
	if not tile or not node:
		return
		
	if not node_can_move_to_tile(node, tile):
	#if tile.piece_in_tile:
		##print("DEBUG: piece already in tile!: ", tile.to_vector())
		return
		
	var center_tile_position: Vector2 = tile.global_position
	var offset: Vector2 = Vector2.ZERO
	center_tile_position.x += tile._x_size / 2
	center_tile_position.y += tile._y_size / 2
	
	if node is Piece:
		node.set_piece_tile(tile)
		tile.piece_in_tile = node
		if node is GenericGiantMonster:
			node.update_giant_monster_tiles()
		tile.trigger_tile_effects(node)
	
	var target_position = center_tile_position + offset
	
	if animate and node is Piece:
		animate_piece_to_position(node, target_position)
	else:
		node.position = target_position

func move_player_x_right(x: int):
	move_piece_x_right(_player, x)

func move_piece_x_right(piece: Piece, x: int, animate: bool = true) -> void:
	var new_tile = BattleController.battlemap.get_tile(piece._tile._x_position + x, piece._tile._y_position)
	if not new_tile:
		return
	piece.set_piece_tile(new_tile)
	new_tile.piece_in_tile = piece
	
	var target_position = Vector2(piece.position.x + 90 * x, piece.position.y)
	if animate:
		animate_piece_to_position(piece, target_position)
	else:
		piece.position = target_position

func node_can_move_to_tile(
	_node_to_place: Node2D,
	_tile_to_move: Tile
) -> bool:
	var _is_piece_in_tile: bool = _tile_to_move.piece_in_tile != null
	if not _node_to_place is GenericGiantMonster:
		return not _is_piece_in_tile
	if _is_piece_in_tile and _tile_to_move.piece_in_tile != _node_to_place:
		return false
	var _giant_monster: GenericGiantMonster = _node_to_place as GenericGiantMonster
	return _giant_monster.is_center_position_valid(_tile_to_move)
