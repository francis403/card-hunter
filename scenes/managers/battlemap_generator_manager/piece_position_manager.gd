extends Node
class_name PiecePositionManager

var _player: PlayerPiece:
	set(player):
		_player = player
		
var _monster: Piece:
	set(monster):
		_monster = monster


func place_piece(piece: Piece, position: Vector2):
	piece.position = position


func place_piece_in_tile(piece: Piece, tile: Tile):
	var piece_position: Vector2 = tile.global_position
	piece_position.x += tile._x_size / 2
	piece_position.y += tile._y_size / 2
	piece.position = piece_position
	piece.set_piece_tile(tile)
	tile.piece_in_tile = piece

func move_player_x_right(x: int):
	move_piece_x_right(_player, x)


func move_piece_x_right(piece: Piece, x: int) -> void:
	piece.position = Vector2(piece.position.x + 90 * x, piece.position.y)
	piece.set_piece_tile(
		BattleController.battlemap.get_tile(piece._tile._x_position + x, piece._tile._y_position)
	)
