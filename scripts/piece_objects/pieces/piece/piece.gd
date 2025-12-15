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

@export_group("Movement Animation")
## Duration of movement animation in seconds
@export var movement_duration: float = 0.3
## Animation curve for movement interpolation
@export var movement_curve: Curve

var base_speed: int

## TODO: maybe rewrite this to be an array of tiles
## Center tile of the monster location. 
## In small monsters this is the only tile the monster will have
## In bigger monters they have more than one tile
var _tile: Tile:
	set(value):
		if _tile:
			previous_tile = _tile.clone()
		#previous_tile = _tile.duplicate() if _tile else null
		_tile = value
		_front_tile = Vector2(
			_tile._x_position - 1,
			_tile._y_position
		)

## Store the position of the monster's previous tile
var previous_tile: Tile = null

## TODO: implement this
## Represents the position of the tile right in front of the monster head 
var _front_tile: Vector2

func _init() -> void:
	base_speed = _speed

func set_piece_tile(tile: Tile):
	if self._tile:
		self._tile.piece_in_tile = null
	self._tile = tile


func apply_damage(
	damage: int,
	_origin_tile: Tile,
	_show_text: bool = true
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

func on_mouse_hover_enter():
	pass

func on_mouse_hover_exit():
	pass
