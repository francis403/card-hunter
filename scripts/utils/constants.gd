extends Node


# ENUMS
enum DeckType {
	DRAW_DECK,
	DISCARD_DECK
}

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
	STRENGTH,
	DAMAGE_TAKEN_MULTIPLIER,
	DAMAGE_DEALT_MULTIPLER,
	DAMAGE
}

enum EffectTrigger {
	ON_SELF_PLAYED,
	ON_EVERY_CARD_PLAY,
	ON_MOVE_CARD_PLAY,
	ON_STATUS_APPLIED,
	ON_START_OF_PLAYER_TURN,
	ON_END_OF_PLAYER_TURN
}

enum TileEffectTypes {
	SPIDER_WEB,
	BLOODIED
}

enum ModulePlacementRule {
	NONE,
	CANNOT_BE_FIRST,
	CANNOT_BE_LAST,
	MUST_BE_FIRST,
	MUST_BE_LAST,
	NEEDS_ATTACK_AFTER,
	NEEDS_ATTACK_BEFORE,
	CANNOT_FOLLOW_SAME_TYPE
}

enum LogicalOperationEnum {
	EQUAL,
	BIGGER_THAN,
	BIGGER_OR_EQUAL,
	SMALLER_THAN,
	SMALLER_OR_EQUAL,
	DIFFERENT_THAN
}

func logical_operation_comparison(
	logical_operation: LogicalOperationEnum,
	x: int,
	y: int
) -> bool:
	match logical_operation:
		LogicalOperationEnum.EQUAL:
			return y == x
		LogicalOperationEnum.BIGGER_THAN:
			return y > x
		LogicalOperationEnum.BIGGER_OR_EQUAL:
			return y >= x
		LogicalOperationEnum.SMALLER_THAN:
			return y < x
		LogicalOperationEnum.SMALLER_OR_EQUAL:
			return y <= x
		LogicalOperationEnum.DIFFERENT_THAN:
			return y != x
	return false

# Constanst

var quest_picker_screen_scroll_scene: PackedScene = load("res://ui/screens/quest_picker/quest_picker_screen.tscn")
var main_world_scroll_scene: PackedScene = load("res://ui/screens/main_world_screen/main_world_screen.tscn")
var pick_class_screen_scene: PackedScene = load("res://ui/screens/pick_class_screen/pick_class_screen.tscn")
var deforge_card_screen_scene: PackedScene = load("res://ui/screens/world_node_screens/deforge_card_screen/deforge_card_screen.tscn")
var forge_card_screen_scene = load("res://ui/screens/forge_card_screen/forge_card_screen.tscn")
var event_screen_scene: PackedScene = load("res://ui/screens/event_screen/event_screen.tscn")
var deck_visualizer_scene: PackedScene = load("res://ui/deck/deck_visualizer/deck_visualizer.tscn")
var card_scene: PackedScene = load("res://scenes/game_objects/cards/card/card.tscn")

const VILLAGE_NODE_ID: String = "village_node_id"
