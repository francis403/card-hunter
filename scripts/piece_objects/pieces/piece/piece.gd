extends CharacterBody2D
class_name Piece

signal piece_took_damage(damage: int)

@export_group("Base Stats")
@export var _health: int = 100
@export var _max_hp: int = _health
@export var _speed: int = 1
@export var _stamina: int = 50
@export var _max_stamina: int = _stamina
@export var _stamina_recover: int = 15
@export var _strength: int = 1

@export_group("Stat Multipliers")
## Modify the value of damage a piece takes.
@export var _damage_taken_multiplier: float = 1.0
## Modify the value of damage a piece deals
@export var _damage_dealt_multiplier: float = 1.0

var base_speed: int
var _tile: Tile

func _init() -> void:
	base_speed = _speed

func set_piece_tile(tile: Tile):
	_tile = tile


func apply_damage(
	damage: int,
	_origin_tile: Tile
):
	var damage_dealt_to_piece: int = damage * _damage_dealt_multiplier
	self._health -= damage_dealt_to_piece
	if self is PlayerPiece:
		BattlemapSignals.player_health_changed.emit(self._health)
	if self is MonsterPiece:
		BattlemapSignals.monster_hp_changed.emit(self._health, self._max_hp)
	piece_took_damage.emit(damage_dealt_to_piece)
	if _health <= 0:
		_die()

func _die():
	self.queue_free()

	
func add_power_effect(_power_effect: BasePowerNodeController):
	pass
	
func remove_all_power_effects():
	pass
	
func remove_power_effect(_status_id: String):
	pass

func has_any_power_effect() -> bool:
	return false

func has_power_effect(_status_id: String) -> bool:
	return false
