extends Node2D

## TODO: need to simplify this code\
## Represents a location in the world
class_name GenericWorldNode

const ID_DICTIONARY_FIELD: String = "id"
const IS_REVEALED_DICTIONARY_FIELD: String = "is_revealed"
const IS_REACHABLE_DICTIONARY_FIELD: String = "is_reachable"
const IS_SHOWING_PLAYER_SPRITE_DICTIONARY_FIELD: String = "is_showing_player_sprite"
const IS_ALREADY_CLICKED_DICTIONARY_FIELD: String = "is_already_clicked"
const IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD: String = "is_only_clickable_once"
const WORLD_NODE_TYPE_DICTIONARY_FIELD: String = "world_node_type"
const NODE_SCENE_PATH_DICTIONARY_FIELD: String = "node_scene"
const POSITION_DICTIONARY_FIELD: String = "position"
const CONNECTIONS_DICTIONARY_FIELD: String = "connections"

@onready var world_node_sprite: Sprite2D = $worldNodeSprite
@onready var player_texture_rect: TextureRect = $HBoxContainer/PlayerTextureRect
@onready var monster_texture_rect: TextureRect = $HBoxContainer/MonsterTextureRect
@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var connections: Array[GenericWorldNode] = []

@export_group("Basic configs")
@export var world_node_id: String
@export var revealed_texture: Texture2D
@export var on_click_scene: PackedScene

@export_group("Extra world node configs")
## Generates random monsters.
## Will add to the monsters_in_node array by default
@export var generate_random_monsters: bool = true
@export var maximum_number_of_monster_to_generate: int = 1
@export var _is_only_clickable_once: bool = true

var is_showing_player_sprite: bool = false
var is_revealed: bool = false
var is_reachable: bool = false
var is_loaded: bool = false
var _is_already_clicked: bool = false

## This needs to be overwritten by every children
var my_node_scene: PackedScene = null
var my_node_scene_path: String = ""

func _init() -> void:
	set_world_scene()
	my_node_scene = load(my_node_scene_path)

func _ready() -> void:
	BattlemapSignals.hide_player_in_other_node.connect(_on_hide_player_in_other_node_signal)
	_prepare_world_node()
	after_node_is_ready()

func _prepare_world_node():
	_prepare_world_node_sprite()
	if self.is_revealed:
		reveal_node_effect()

func _prepare_world_node_sprite():
	if File.progress.current_world_node_id == world_node_id:
		show_player()
	
func _on_hide_player_in_other_node_signal(node_id: String):
	if world_node_id != node_id:
		hide_player()

func reveal_connected_nodes():
	for node in self.connections:
		node.reveal_node()
	BattlemapSignals.world_updated.emit()

## Function to be overwritten by the different types of nodes
func reveal_node_effect():
	if revealed_texture:
		world_node_sprite.texture = revealed_texture
	
## Function to be overwritten that defines what happens when a node is clicked
func on_node_click_event():
	if not _is_click_event_processable():
		return
	var scene = on_click_scene.instantiate()
	var scene_signal: String = "world_node_screen_completed"
	if scene.has_signal(scene_signal) and\
		not scene.is_connected(scene_signal, _on_world_node_screen_completed_signal):
			scene.connect(scene_signal, _on_world_node_screen_completed_signal)
	if scene is WorldNodeScreen:
		scene._world_node_scene = self
	get_tree().root.add_child(scene)
	self._is_already_clicked = true
	
func _on_world_node_screen_completed_signal(_advance_day: bool):
	BattlemapSignals.world_node_screen_completed.emit(_advance_day)
	self.reveal_connected_nodes()

## Function that has to be overwritten
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/generic_world_node/generic_world_node.tscn"
	
## Function that has to be overwritten
## occurres at the end of the Ready Function
func after_node_is_ready():
	pass

## Function that can be overwritten
## Checks if the node can be clicked
func _is_click_event_processable() -> bool:
	return on_click_scene != null and on_click_scene.can_instantiate()\
			and not (self._is_already_clicked and self._is_only_clickable_once)

## Function that can be overwritten
## Occurs after the world node is completed
func after_world_node_completed_successfully():
	BattlemapSignals.node_completed.emit(self.world_node_id)

func override_world_node_reward(
	_rewards: Array[CardResourceV2],
	_number_of_choices: int
):
	pass


func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_pressed():
		_process_on_world_node_click()

func _process_on_world_node_click():
	## TODO: show a message
	if not self.is_reachable:
		return
	
	if self.is_showing_player_sprite:
		on_node_click_event()
	
	self.show_player()
	
	File.progress.update_player_position(self)
	
	## Tell the game to save 
	BattlemapSignals.player_world_state_updated.emit(self)
	if audio_stream_player:
		audio_stream_player.play()
		await audio_stream_player.finished
	
	
func hide_player():
	is_showing_player_sprite = false
	if player_texture_rect:
		player_texture_rect.visible = false

func show_player():
	is_showing_player_sprite = true
	player_texture_rect.visible = true

func reveal_node():
	if self.is_revealed:
		return
	self.is_revealed = true
	_mark_reachable()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	tween = create_tween()
	reveal_node_effect()
	tween.tween_property(self, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	BattlemapSignals.node_finished_revealing.emit(self.world_node_id)

func _mark_reachable():
	self.is_reachable = true
	
func duplicate_node(instantite_node_copy: bool = false) -> GenericWorldNode:
	var node_copy: GenericWorldNode = null
	if instantite_node_copy:
		node_copy = my_node_scene.instantiate()
	else:
		node_copy = GenericWorldNode.new()
	self.copy_properties_into_node(node_copy)
	for child in self.connections:
		node_copy.connections.append(child.duplicate_node(instantite_node_copy))
	return node_copy

func copy_into_node(node: GenericWorldNode, instantiate_node: bool = false) -> void:
	self.copy_properties_into_node(node)
	node.connections.clear()
	for child in self.connections:
		node.connections.append(child.duplicate_node(instantiate_node))

func copy_properties_into_node(node: GenericWorldNode):
	node.world_node_id = self.world_node_id
	node.position = self.position
	node.is_revealed = self.is_revealed
	node.is_reachable = self.is_reachable
	node.is_showing_player_sprite = self.is_showing_player_sprite

func convert_node_to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	result[ID_DICTIONARY_FIELD] = self.world_node_id
	result[IS_REVEALED_DICTIONARY_FIELD] = self.is_revealed
	result[IS_REACHABLE_DICTIONARY_FIELD] = self.is_reachable
	result[IS_SHOWING_PLAYER_SPRITE_DICTIONARY_FIELD] = self.is_showing_player_sprite
	result[IS_ALREADY_CLICKED_DICTIONARY_FIELD] = self._is_already_clicked
	result[IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD] = self._is_only_clickable_once
	result[POSITION_DICTIONARY_FIELD] = self.position
	result[NODE_SCENE_PATH_DICTIONARY_FIELD] = self.my_node_scene_path
	result[CONNECTIONS_DICTIONARY_FIELD] = {}
	return result
	
func load_node_from_dictionary(node_state: Dictionary):
	self.world_node_id = node_state[ID_DICTIONARY_FIELD]
	self.is_revealed = node_state[IS_REVEALED_DICTIONARY_FIELD]
	self.is_reachable = node_state[IS_REACHABLE_DICTIONARY_FIELD]
	self.is_showing_player_sprite = node_state[IS_SHOWING_PLAYER_SPRITE_DICTIONARY_FIELD]
	if self.is_showing_player_sprite:
		PlayerController.current_world_node = self
	if node_state.has(IS_ALREADY_CLICKED_DICTIONARY_FIELD):
		self._is_already_clicked = node_state[IS_ALREADY_CLICKED_DICTIONARY_FIELD]
	if node_state.has(IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD):
		self._is_only_clickable_once = node_state[IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD]
	self.my_node_scene_path = node_state[NODE_SCENE_PATH_DICTIONARY_FIELD]
	self.my_node_scene = load(my_node_scene_path)
	self.position = node_state[POSITION_DICTIONARY_FIELD] 
