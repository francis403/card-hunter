extends Node
class_name Constants


# ENUMS

enum TargetType {
	INHERIT,
	SELF,
	MONSTER,
	PLAYER
}

enum AreaType {
	INHERIT,
	NONE,
	SPECIFIC,
	LINE, 
	RADIUS, 
	CROSS, 
	SHOTGUN,
	UP_TO_RANGE_SKIPPING_FIRST
}

enum StatType {
	MAX_STAMINA,
	STAMINA,
	MAX_HEALTH,
	HEALTH,
	MAX_SPEED,
	SPEED,
	DAMAGE
}


# Constanst
const deck_visualizer_scene = preload("res://ui/deck/deck_visualizer/deck_visualizer.tscn")
const pick_class_screen_scene = preload("res://ui/screens/pick_class_scren/pick_class_screen.tscn")
const quest_picker_screen_scroll_scene = preload("res://ui/screens/quest_picker/quest_picker_screen.tscn")
