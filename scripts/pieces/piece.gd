extends CharacterBody2D
class_name Piece

@export var _health: int = 100
@export var _max_hp: int = _health
@export var _speed: int = 1
@export var _stamina: int = 50
@export var _max_stamina: int = _stamina
@export var _stamina_recover: int = 15
@export var _strength: int = 1

var _tile: Tile

func set_piece_tile(tile: Tile):
	_tile = tile


func apply_damage(damage: int):
	self._health -= damage
	BattlemapSignals.player_health_changed.emit(self._health)
	if _health <= 0:
		_die()

func _die():
	self.queue_free()
