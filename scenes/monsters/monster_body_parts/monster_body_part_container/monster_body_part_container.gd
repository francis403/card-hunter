extends Node2D

## Holds all body parts as children
class_name MonsterBodyPartContainer

signal monster_body_part_hit(body_part: BodyPart)

@export var debug_mode: bool = false

## TODO: in the future I will need more than one tile
func init_body_parts(tile: Tile):
	for child: BodyPart in self.get_children():
		child.body_part_tile_location = tile

func get_and_hit_body_parts(
	angle: float,
	damage: int
) -> Array[BodyPart]:
	if debug_mode:
		print(get_and_hit_body_parts, ": angle = ", angle)
	var result: Array[BodyPart] = []
	## TODO: need to check if the tile attacked is actually where the body part is
	for child: BodyPart in self.get_children():
		if child.is_body_part_hit(angle):
			if debug_mode:
				print(get_and_hit_body_parts, ": ", child.body_part_type, " hit!")
			result.append(child)
			child.hit_body_part(damage)
			self.monster_body_part_hit.emit(child)
		else:
			if debug_mode:
				print(get_and_hit_body_parts, ": ", child.body_part_type, " missed")
	if result.is_empty():
		_emit_none_body_part()
		
	return result

func _emit_none_body_part() -> void:
	var none_body_part = BodyPart.new()
	none_body_part.body_part_type = BodyPart.BodyPartType.NONE
	self.monster_body_part_hit.emit(none_body_part)

## TODO: need to improve this for when there are monsters with more than one tile
func _rotate_body_parts(
	center_tile: Tile,
	initial_angle_rad: float,
	new_angle_rad: float
):
	var initial_angle: float = rad_to_deg(initial_angle_rad)
	var new_angle: float = rad_to_deg(new_angle_rad)
	var angle_dif: float = snappedf(new_angle, 0) - snappedf(initial_angle, 0)
	for child: BodyPart in self.get_children():
		child.rotate_body_part(angle_dif)
	queue_redraw()
	

# Debug function to visualize body part angles
func _draw():
	#if not Engine.is_editor_hint():
		#return
	if not debug_mode:
		return
	
	var center = Vector2.ZERO
	var radius = 15.0
	
	for part: BodyPart in self.get_children():
		if part.is_severed:
			continue
			
		if not part.draw_angle_ranges:
			continue
		
		var color = Color.GREEN if not part.is_broken else Color.RED
		if part.is_weakpoint:
			color = Color.YELLOW
		
		# Draw arc for body part angle range
		var start_angle = deg_to_rad(part.current_min_angle)
		var end_angle = deg_to_rad(part.current_max_angle)
		
		# Handle wrap-around
		if part.current_min_angle > part.current_max_angle:
			# Draw two arcs
			draw_arc(center, radius, start_angle, deg_to_rad(360), 32, color, 3.0)
			draw_arc(center, radius, 0, end_angle, 32, color, 3.0)
			#draw_arc(center, radius, start_angle, end_angle, 32, color, 3.0)
		else:
			draw_arc(center, radius, start_angle, end_angle, 32, color, 3.0)
