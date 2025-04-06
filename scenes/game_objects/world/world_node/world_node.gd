extends Node2D

## TODO: need to simplify this code\
##
class_name WorldNode

const REVEALED_NODE_SPRITE = preload("res://assets/images/nodes/revealed_node.png")
const VILAGE_NODE_SPRITE = preload("res://assets/images/nodes/vilage_node.png")
const QUESTION_MARK_NODE_TRANSPARENT_SPRITE = preload("res://assets/images/nodes/question_mark_node-transparent.png")

const BATTLE_GENERIC_SCENE = preload("res://scenes/battle_scenes/battle_generic_scene/battle_generic_scene.tscn")

const CRAB_MONSTER_SCENE = preload("res://scenes/monsters/CrabMonster/crab_monster.tscn")
const SPIDER_MONSTER_SCENE = preload("res://scenes/monsters/spider_monster/spider_monster.tscn")

const ID_DICTIONARY_FIELD: String = "id"
const IS_REVEALED_DICTIONARY_FIELD: String = "is_revealed"
const IS_REACHABLE_DICTIONARY_FIELD: String = "is_reachable"
const IS_SHOWING_PLAYER_SPRITE_DICTIONARY_FIELD: String = "is_showing_player_sprite"
const WORLD_NODE_TYPE_DICTIONARY_FIELD: String = "world_node_type"
const POSITION_DICTIONARY_FIELD: String = "position"
const CONNECTIONS_DICTIONARY_FIELD: String = "connections"
const MONSTERS_DICTIONARY_FIELD: String = "monsters"

enum WorldNodeTypeEnum {
	VILLAGE,
	UNKNOWN,
	REVEALED
}

@onready var world_node_sprite: Sprite2D = $worldNodeSprite
@onready var player_texture_rect: TextureRect = $HBoxContainer/PlayerTextureRect
@onready var monster_texture_rect: TextureRect = $HBoxContainer/MonsterTextureRect
@onready var area_2d: Area2D = $Area2D

@export var _world_node_type: WorldNodeTypeEnum = WorldNodeTypeEnum.UNKNOWN
@export var connections: Array[WorldNode] = []

@export_category("Monsters in node")
@export var monsters_in_node: Array[GenericMonster] = []

## Generates random monsters.
## Will add to the monsters_in_node array by default
@export var generate_random_monsters: bool = true
@export var maximum_number_of_monster_to_generate: int = 1
@export var quest_scene: PackedScene

var world_node_id: String
var is_showing_player_sprite: bool = false
var is_revealed: bool = false
var is_reachable: bool = false
var is_loaded: bool = false

func _ready() -> void:
	BattlemapSignals.hide_player_in_other_node.connect(_on_hide_player_in_other_node_signal)
	BattlemapSignals.reveal_node.connect(_on_node_reveal_signal)
	BattlemapSignals.node_completed.connect(_on_node_complete_signal)
	_prepare_world_node()
	

func _on_hide_player_in_other_node_signal(node_id: String):
	if world_node_id != node_id:
		hide_player()

func _on_node_reveal_signal(world_node_id: String):
	if self.world_node_id == world_node_id:
		self.reveal_node()

func _on_node_complete_signal(world_node_id: String):
	if self.world_node_id != world_node_id:
		return
	monster_texture_rect.visible = false
	monsters_in_node.clear()
	BattlemapSignals.reveal_connected_nodes.emit(self)

func _prepare_world_node_sprite():
	if _world_node_type == WorldNodeTypeEnum.VILLAGE:
		world_node_sprite.texture = VILAGE_NODE_SPRITE
	elif _world_node_type == WorldNodeTypeEnum.REVEALED:
		world_node_sprite.texture = REVEALED_NODE_SPRITE
		
	if File.progress.current_world_node_id == world_node_id:
		show_player()

func _prepare_world_node():
	_prepare_world_node_sprite()
	if self.is_revealed:
		show_monster()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		_process_on_world_node_click()

func _process_on_world_node_click():
	print(_process_on_world_node_click)
	
	## TODO: generate combat based on the monster there
	## TODO: append info of monsters to fight in battle_controller
	## 		then generic scene on start reads from there
	if self.is_showing_player_sprite && _has_quest():
		
		var battle_scene: BattleGenericScene = BATTLE_GENERIC_SCENE.instantiate()
		battle_scene.monsters.clear()
		for monster in monsters_in_node:
			battle_scene.monsters.append(monster)
		get_tree().root.add_child(battle_scene)
		
	## TODO: show a message
	if not self.is_reachable:
		return
		
	self.show_player()
	BattlemapSignals.update_player_node.emit(world_node_id)
	BattlemapSignals.hide_player_in_other_node.emit(world_node_id)

## TODO: add the ability for more than just battling mosnters
func _has_quest():
	return monsters_in_node.size() > 0
	
func hide_player():
	is_showing_player_sprite = false
	player_texture_rect.visible = false

func show_player():
	is_showing_player_sprite = true
	player_texture_rect.visible = true
	
## TODO: show monster that is there
func show_monster():
	if monsters_in_node.size() > 0:
		monster_texture_rect.texture = monsters_in_node[0].get_texture()
		monster_texture_rect.visible = true

func reveal_node():
	if is_revealed:
		return
	is_revealed = true
	mark_reachable()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	tween = create_tween()
	mark_revealed()
	show_monster()
	tween.tween_property(self, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	BattlemapSignals.node_finished_revealing.emit(self.world_node_id)

func mark_reachable():
	self.is_reachable = true

func mark_revealed():
	world_node_sprite.texture = REVEALED_NODE_SPRITE
	_world_node_type = WorldNodeTypeEnum.REVEALED
	
func duplicate_node() -> WorldNode:
	var node_copy: WorldNode = WorldNode.new()
	self.copy_properties_into_node(node_copy)
	for child in self.connections:
		node_copy.connections.append(child.duplicate_node())
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
	node.is_reachable = self.is_reachable
	node.is_showing_player_sprite = self.is_showing_player_sprite
	node._world_node_type = self._world_node_type
	for child_monster in self.monsters_in_node:
		node.monsters_in_node.append(child_monster)

func convert_node_to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	result[ID_DICTIONARY_FIELD] = self.world_node_id
	result[IS_REVEALED_DICTIONARY_FIELD] = self.is_revealed
	result[IS_REACHABLE_DICTIONARY_FIELD] = self.is_reachable
	result[IS_SHOWING_PLAYER_SPRITE_DICTIONARY_FIELD] = self.is_showing_player_sprite
	result[POSITION_DICTIONARY_FIELD] = self.position
	result[WORLD_NODE_TYPE_DICTIONARY_FIELD] = self._world_node_type
	result[CONNECTIONS_DICTIONARY_FIELD] = {}
	result[MONSTERS_DICTIONARY_FIELD] = {}
	var i: int = 0
	for child_monster in self.monsters_in_node:
		result[MONSTERS_DICTIONARY_FIELD][i] = child_monster.monster_id
		i += 1
	return result
	
func load_node_from_dictionary(node_state: Dictionary):
	self.world_node_id = node_state[ID_DICTIONARY_FIELD]
	self.is_revealed = node_state[IS_REVEALED_DICTIONARY_FIELD]
	self.is_reachable = node_state[IS_REACHABLE_DICTIONARY_FIELD]
	self.is_showing_player_sprite = node_state[IS_SHOWING_PLAYER_SPRITE_DICTIONARY_FIELD]
	self._world_node_type = node_state[WORLD_NODE_TYPE_DICTIONARY_FIELD] 
	self.position = node_state[POSITION_DICTIONARY_FIELD] 
	## TODO: this needs to be smarter
	self.monsters_in_node = []
	for monster_id in node_state[MONSTERS_DICTIONARY_FIELD].keys():
		if node_state[MONSTERS_DICTIONARY_FIELD][monster_id] == "crab_monster_small":
			self.monsters_in_node.append(CRAB_MONSTER_SCENE.instantiate())
		else:
			self.monsters_in_node.append(SPIDER_MONSTER_SCENE.instantiate())
