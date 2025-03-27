extends Node2D
class_name WorldNode

const QUESTION_MARK_NODE_SPRITE = preload("res://assets/images/nodes/question_mark_node.png")
const VILAGE_NODE_SPRITE = preload("res://assets/images/nodes/vilage_node.png")

enum WorldNodeTypeEnum {
	VILLAGE,
	UNKNOWN
}

@onready var world_node_sprite: Sprite2D = $worldNodeSprite

@export var _world_node_type: WorldNodeTypeEnum = WorldNodeTypeEnum.UNKNOWN
@export var connections: Array[WorldNode] = []
@export var quest_scene: PackedScene

var world_node_id: String

func _ready() -> void:
	_prepare_world_node_sprite()

## TODO
func _prepare_world_node_sprite():
	if _world_node_type == WorldNodeTypeEnum.VILLAGE:
		world_node_sprite.texture = VILAGE_NODE_SPRITE


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		print(_on_area_2d_input_event)
		if quest_scene:
			get_tree().change_scene_to_packed(quest_scene)
