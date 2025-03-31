extends Node2D
class_name WorldNode

const REVEALED_NODE_SPRITE = preload("res://assets/images/nodes/revealed_node.png")
const VILAGE_NODE_SPRITE = preload("res://assets/images/nodes/vilage_node.png")
const QUESTION_MARK_NODE_TRANSPARENT_SPRITE = preload("res://assets/images/nodes/question_mark_node-transparent.png")

enum WorldNodeTypeEnum {
	VILLAGE,
	UNKNOWN,
	REVEALED
}

@onready var world_node_sprite: Sprite2D = $worldNodeSprite
@onready var player_texture_rect: TextureRect = $HBoxContainer/PlayerTextureRect
@onready var monster_texture_rect: TextureRect = $HBoxContainer/MonsterTextureRect


@export var _world_node_type: WorldNodeTypeEnum = WorldNodeTypeEnum.UNKNOWN
@export var connections: Array[WorldNode] = []

@export_category("Monsters in node")
@export var monsters_in_node: Array[MonsterPiece] = []
## Generates random monsters.
## Will add to the monsters_in_node array by default
@export var generate_random_monsters: bool = true
@export var maximum_number_of_monster_to_generate: int = 1
@export var quest_scene: PackedScene

var world_node_id: String
var is_showing_player_sprite: bool = false
var is_revealed: bool = false
var is_loaded: bool = false

func _ready() -> void:
	BattlemapSignals.hide_player_in_other_node.connect(_on_hide_player_in_other_node_signal)
	BattlemapSignals.reveal_node.connect(_on_node_reveal_signal)
	_prepare_world_node_sprite()
	

func _on_hide_player_in_other_node_signal(node_id: String):
	if world_node_id != node_id:
		hide_player()

func _on_node_reveal_signal(world_node_id: String):
	if self.world_node_id == world_node_id:
		self.reveal_node()

## TODO
func _prepare_world_node_sprite():
	if _world_node_type == WorldNodeTypeEnum.VILLAGE:
		world_node_sprite.texture = VILAGE_NODE_SPRITE
	elif _world_node_type == WorldNodeTypeEnum.REVEALED:
		world_node_sprite.texture = REVEALED_NODE_SPRITE
		
	if File.progress.current_world_node_id == world_node_id:
		show_player()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		_process_on_world_node_click()

func _process_on_world_node_click():
	if self.is_showing_player_sprite && quest_scene:
		get_tree().change_scene_to_packed(quest_scene)
	show_player()
	BattlemapSignals.update_player_node.emit(world_node_id)
	BattlemapSignals.hide_player_in_other_node.emit(world_node_id)
	BattlemapSignals.generate_world_node_children.emit(self)

func hide_player():
	is_showing_player_sprite = false
	player_texture_rect.visible = false

func show_player():
	is_showing_player_sprite = true
	player_texture_rect.visible = true
	
func show_monster():
	monster_texture_rect.visible = true

func reveal_node():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	tween = create_tween()
	world_node_sprite.texture = REVEALED_NODE_SPRITE
	show_monster()
	tween.tween_property(self, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func duplicate_node() -> WorldNode:
	var node_copy: WorldNode = WorldNode.new()
	self.copy_properties_into_node(node_copy)
	for node in self.connections:
		node_copy.connections.append(node.duplicate_node())
	return node_copy

func copy_into_node(node: WorldNode) -> void:
	self.copy_properties_into_node(node)
	node.connections.clear()
	for child in self.connections:
		node.connections.append(child.duplicate_node())

func copy_properties_into_node(node: WorldNode):
	node.world_node_id = self.world_node_id
	node.position = self.position
	node.is_revealed = self.is_revealed
	node.is_showing_player_sprite = self.is_showing_player_sprite
	node._world_node_type = self._world_node_type
	for child_monster in self.monsters_in_node:
		node.monsters_in_node.append(child_monster)
