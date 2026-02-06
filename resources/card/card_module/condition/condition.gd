extends CardModule
class_name Condition

@export_group("Card Module Color Configuration")
@export var top_section_background_color: Color = Color(0.124, 0.15, 0.153)
@export var bottom_section_background_color: Color = Color(0.384, 0.384, 0.384)

func is_condition_meet() -> bool:
	return false

func _get_my_node_scene_path() -> String:
	return "res://resources/card/card_module/condition/condition.gd"
