extends Node

## Represents the body part of a Monster
class_name BodyPart

enum BodyPartType {
	NONE,
	HEAD,
	TAIL,
	WING,
	LEG,
	BACK,
	BELLY,
	HORN,
	CLAW,
	CORE
}

@export_group("Basic Data configuration")
## A body part will be located in a body part.
## One tile can have more than one body part
@export var body_part_tile_location: Tile
@export var part_name: String
@export var body_part_type: BodyPartType
@export var body_part_health: int = 10

## Angle range this body part covers (in degrees)
@export_group("Hit Configuration")
@export var min_angle: float
@export var max_angle: float
@export var damage_multiplier: float = 1.0
@export var is_weakpoint: bool = false
@export var is_broken: bool = false
@export var is_severed: bool = false

@export_group("On Break Configuration")
@export var can_be_broken: bool = true
@export var materials_dropped: Array[String] = []
## Override the damage_multipler
@export var broken_damage_multiplier: float = 1.0

@export_group("Debug Configuration")
@export var draw_angle_ranges: bool = true

## The angle of the body parts changes if the tile they are on is rotated
var current_min_angle: float
var current_max_angle: float

func _ready() -> void:
	current_min_angle = min_angle
	current_max_angle = max_angle

func is_body_part_hit(angle: float) -> bool:
	return is_angle_in_range(angle)

func is_angle_in_range(angle: float) -> bool:
	var round_down_angle: float = snappedf(angle, 0)
	if current_min_angle <= current_max_angle:
		return round_down_angle >= current_min_angle and round_down_angle <= current_max_angle
	else:
		return round_down_angle >= current_min_angle or round_down_angle <= current_max_angle

func hit_body_part(damage: int):
	_deal_damage(damage)

func rotate_body_part(rotation: float):
	current_min_angle = _sum_rotation(current_min_angle, rotation)
	current_max_angle = _sum_rotation(current_max_angle, rotation)
	
func _sum_rotation(current_angle: float, rotation: float) -> float:
	var result: float = snappedf(current_angle, 0) + snappedf(rotation, 0)
	var temp_result: float = fmod(abs(result), 360)
	if result < 0:
		return 360 - temp_result
	elif result > 360:
		return temp_result
	return result

func _deal_damage(damage: int):
	if is_broken:
		return
	body_part_health -= damage
	if body_part_health <= 0 and self.can_be_broken:
		_on_body_part_break()

func _on_body_part_break():
	self.is_broken = true
