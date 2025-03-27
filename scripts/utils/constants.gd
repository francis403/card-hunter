extends Node


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

var quest_picker_screen_scroll_scene = load("res://ui/screens/quest_picker/quest_picker_screen.tscn")
var main_world_scroll_scene = load("res://ui/screens/main_world_screen/main_world_screen.tscn")
var pick_class_screen_scene = load("res://ui/screens/pick_class_screen/pick_class_screen.tscn")

const deck_visualizer_scene = preload("res://ui/deck/deck_visualizer/deck_visualizer.tscn")
const card_scene = preload("res://scenes/game_objects/cards/card/card.tscn")
