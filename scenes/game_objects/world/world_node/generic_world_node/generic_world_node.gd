extends Node2D

## Represents a location in the world
class_name GenericWorldNode

signal world_node_complete(_node: GenericWorldNode)

const ID_DICTIONARY_FIELD: String = "id"
const IS_REVEALED_DICTIONARY_FIELD: String = "is_revealed"
const IS_REACHABLE_DICTIONARY_FIELD: String = "is_reachable"
const IS_ALREADY_CLICKED_DICTIONARY_FIELD: String = "is_already_clicked"
const IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD: String = "is_only_clickable_once"
const WORLD_NODE_TYPE_DICTIONARY_FIELD: String = "world_node_type"
const NODE_SCENE_PATH_DICTIONARY_FIELD: String = "node_scene"
const POSITION_DICTIONARY_FIELD: String = "position"
const TABLE_POSITION_DICTIONARY_FIELD: String = "table_position"
const CONNECTIONS_DICTIONARY_FIELD: String = "connections"
# Key for boss-node flag in save dictionary
const IS_BOSS_NODE_DICTIONARY_FIELD: String = "is_boss_node"

@onready var world_node_sprite: Sprite2D = $worldNodeSprite
@onready var player_texture_rect: TextureRect = $HBoxContainer/PlayerTextureRect
@onready var monster_texture_rect: TextureRect = $HBoxContainer/MonsterTextureRect
@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var connections: Array[GenericWorldNode] = []
var pulsating_tween: Tween

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
@export var _is_pulsable: bool = true

## When using table generation might be useful to have the info here
var table_position: Vector2 = Vector2(-1, -1)

var _available_tween_scale: Vector2 = Vector2(1.1, 1.1)

var is_revealed: bool = false
var is_reachable: bool = false
var is_loaded: bool = false
var _is_already_clicked: bool = false:
	set(value):
		_is_already_clicked = value
		if _is_already_clicked:
			_stop_pulsating()

## Marks this node as the final boss encounter node
var _is_boss_node: bool = false

## This needs to be overwritten by every children
var my_node_scene: PackedScene = null
var my_node_scene_path: String = ""

func _init() -> void:
	set_world_scene()
	my_node_scene = load(my_node_scene_path)

func _ready() -> void:
	_prepare_world_node()
	after_node_is_ready()

func _prepare_world_node():
	_prepare_world_node_sprite()
	if self.is_revealed:
		reveal_node_effect()
		if not self._is_already_clicked:
			_start_pulsating_animation()

func _prepare_world_node_sprite():
	if File.progress.current_world_node_id == world_node_id:
		show_player()

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
	self._is_already_clicked = true
	get_tree().root.add_child(scene)

func _on_world_node_screen_completed_signal(_advance_day: bool):
	BattlemapSignals.world_node_screen_completed.emit(_advance_day)
	self.world_node_complete.emit(self)
	self.reveal_connected_nodes()

## Function that has to be overwritten
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/generic_world_node/generic_world_node.tscn"

## Function that has to be overwritten
## occurs at the end of the Ready Function
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
	self.world_node_complete.emit(self)

func override_world_node_reward(
	_rewards: Array[CardResourceV2],
	_number_of_choices: int
):
	pass


func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_pressed():
		_process_on_world_node_click()

## Handles a click on this world node.
## show_player() is only called after the node-id is confirmed so the player
## icon never appears on a node whose position hasn't been committed yet (Issue 5).
func _process_on_world_node_click():
	if not self.is_reachable:
		return

	# Persist the navigation move unconditionally for any reachable node
	File.update_player_position(self)
	BattlemapSignals.player_world_state_updated.emit(self)

	# Only display the player icon and trigger the node action once the
	# engine's tracked position agrees with this node's id
	if self.world_node_id == GameController.current_player_node_id:
		show_player()
		on_node_click_event()

	if audio_stream_player:
		audio_stream_player.play()
		await audio_stream_player.finished


func hide_player():
	if player_texture_rect:
		player_texture_rect.visible = false

func show_player():
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

	## Update the world state for the revealed nodes
	BattlemapSignals.player_world_state_updated.emit(self)

	BattlemapSignals.node_finished_revealing.emit(self.world_node_id)
	_start_pulsating_animation()

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
	node.world_node_id  = self.world_node_id
	node.position       = self.position
	node.is_revealed    = self.is_revealed
	node.is_reachable   = self.is_reachable
	# Propagate boss flag when copying
	node._is_boss_node  = self._is_boss_node

func convert_node_to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	result[ID_DICTIONARY_FIELD]                    = self.world_node_id
	result[IS_REVEALED_DICTIONARY_FIELD]           = self.is_revealed
	result[IS_REACHABLE_DICTIONARY_FIELD]          = self.is_reachable
	result[IS_ALREADY_CLICKED_DICTIONARY_FIELD]    = self._is_already_clicked
	result[IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD] = self._is_only_clickable_once
	result[POSITION_DICTIONARY_FIELD]              = self.position
	result[TABLE_POSITION_DICTIONARY_FIELD]        = self.table_position
	result[NODE_SCENE_PATH_DICTIONARY_FIELD]       = self.my_node_scene_path
	# Persist boss flag so load restores correct behaviour
	result[IS_BOSS_NODE_DICTIONARY_FIELD]          = self._is_boss_node
	result[CONNECTIONS_DICTIONARY_FIELD] = {}
	for _con in connections:
		result[CONNECTIONS_DICTIONARY_FIELD][_con.world_node_id] = true
	return result

func load_node_from_dictionary(node_state: Dictionary):
	self.world_node_id  = node_state[ID_DICTIONARY_FIELD]
	self.is_revealed    = node_state[IS_REVEALED_DICTIONARY_FIELD]
	self.is_reachable   = node_state[IS_REACHABLE_DICTIONARY_FIELD]
	if node_state.has(IS_ALREADY_CLICKED_DICTIONARY_FIELD):
		self._is_already_clicked = node_state[IS_ALREADY_CLICKED_DICTIONARY_FIELD]
	if node_state.has(IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD):
		self._is_only_clickable_once = node_state[IS_ONLY_CLICKABLE_ONCE_DICTIONARY_FIELD]
	# Restore boss flag (default false for old saves that lack the key)
	if node_state.has(IS_BOSS_NODE_DICTIONARY_FIELD):
		self._is_boss_node = node_state[IS_BOSS_NODE_DICTIONARY_FIELD]
	self.my_node_scene_path = node_state[NODE_SCENE_PATH_DICTIONARY_FIELD]
	self.my_node_scene      = load(my_node_scene_path)
	self.position           = node_state[POSITION_DICTIONARY_FIELD]
	self.table_position     = node_state[TABLE_POSITION_DICTIONARY_FIELD]
	_start_pulsating_animation()

func _start_pulsating_animation() -> void:
	if not _is_pulsable:
		return
	if is_revealed and not _is_already_clicked:
		_start_pulsating()
		return
	if pulsating_tween and pulsating_tween.is_running():
		_stop_pulsating()

func _start_pulsating() -> void:
	if pulsating_tween and pulsating_tween.is_running():
		_stop_pulsating()
	pulsating_tween = create_tween()
	if world_node_sprite:
		pulsating_tween.set_loops()
		pulsating_tween.tween_property(world_node_sprite, "scale", _available_tween_scale, 0.8)
		pulsating_tween.tween_property(world_node_sprite, "scale", Vector2.ONE, 0.8)
		pulsating_tween.set_ease(Tween.EASE_IN_OUT)
		pulsating_tween.set_trans(Tween.TRANS_SINE)

func _stop_pulsating() -> void:
	if pulsating_tween:
		pulsating_tween.kill()
		pulsating_tween = null
	if world_node_sprite:
		world_node_sprite.scale = Vector2.ONE