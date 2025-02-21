extends CharacterBody2D
class_name Piece

@export var _health: int = 100
@export var _movement: int = 1

var _tile: Tile


func set_piece_tile(tile: Tile):
	_tile = tile


func apply_damage(damage: int):
	pass
