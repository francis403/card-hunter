extends Node2D
class_name WorldNode

const QUESTION_MARK_NODE_SPRITE = preload("res://assets/images/nodes/question_mark_node.png")
const VILAGE_NODE_SPRITE = preload("res://assets/images/nodes/vilage_node.png")

enum WorldNodeTypeEnum {
	VILLAGE,
	UNKNOWN
}

@onready var world_node_sprite: Sprite2D = $worldNodeSprite
@onready var player_sprite: Sprite2D = $PlayerSprite

@export var _world_node_type: WorldNodeTypeEnum = WorldNodeTypeEnum.UNKNOWN
@export var connections: Array[WorldNode] = []
@export var quest_scene: PackedScene
var is_showing_player_sprite: bool = false

var world_node_id: String

func _ready() -> void:
	BattlemapSignals.hide_player_in_other_node.connect(_on_hide_player_in_other_node_signal)
	_prepare_world_node_sprite()

func _on_hide_player_in_other_node_signal(node_id: String):
	if world_node_id != node_id:
		hide_player()

## TODO
func _prepare_world_node_sprite():
	if _world_node_type == WorldNodeTypeEnum.VILLAGE:
		world_node_sprite.texture = VILAGE_NODE_SPRITE
	
	if File.progress.current_world_node_id == world_node_id:
		show_player()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		_process_on_world_node_click()

func _process_on_world_node_click():
	print(_process_on_world_node_click)
	show_player()
	BattlemapSignals.update_player_node.emit(world_node_id)
	BattlemapSignals.hide_player_in_other_node.emit(world_node_id)

func hide_player():
	is_showing_player_sprite = false
	player_sprite.visible = false

func show_player():
	is_showing_player_sprite = true
	player_sprite.visible = true
