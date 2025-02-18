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
