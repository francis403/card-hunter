extends CharacterBody2D
class_name Piece

@export var _health: int = 100
@export var _speed: int = 1
@export var _stamina: int = 50
@export var _strength: int = 1

var _tile: Tile


func set_piece_tile(tile: Tile):
	_tile = tile


func apply_damage(damage: int):
	pass
