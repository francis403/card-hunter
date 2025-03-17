extends Node
class_name PiecePositionManager

var _player: PlayerPiece:
	set(player):
		_player = player
		


func place_piece(piece: Piece, position: Vector2):
	piece.position = position


func place_piece_in_tile(piece: Piece, tile: Tile):
	place_node_in_tile(piece, tile)

func place_node_in_tile(node: Node2D, tile: Tile):
	if not tile:
		return
	if tile.piece_in_tile:
		return
		
	var center_tile_position: Vector2 = tile.global_position
	var offset: Vector2 = Vector2.ZERO
	center_tile_position.x += tile._x_size / 2
	center_tile_position.y += tile._y_size / 2
	if node is Piece:
		#update the old tile
		if node._tile:
			node._tile.piece_in_tile = null
		node.set_piece_tile(tile)
		tile.piece_in_tile = node
	node.position = center_tile_position + offset

func move_player_x_right(x: int):
	move_piece_x_right(_player, x)


func move_piece_x_right(piece: Piece, x: int) -> void:
	piece.position = Vector2(piece.position.x + 90 * x, piece.position.y)
	piece.set_piece_tile(
		BattleController.battlemap.get_tile(piece._tile._x_position + x, piece._tile._y_position)
	)
