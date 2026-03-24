extends ReferenceRect
class_name Tile


var _x_position: int
var _y_position: int
var _x_size: int = 40
var _y_size: int = 40
var is_tile_attacked: bool = false
var piece_in_tile: Piece = null:
	set(_value):
		piece_in_tile = _value
		_toggle_tile_occuppied_view()
		_toggle_monster_highlight()

var _show_if_tile_is_occupied: bool = false

@export var show_status: bool = false

@onready var background_button: Button = $BackgroundButton
@onready var status_label: Label = $StatusLabel
@onready var attack_rect: ColorRect = $AttackRect
@onready var monster_rect: ColorRect = $MonsterRect
@onready var tile_effects_container: Control = %TileEffectsContainer


func _ready() -> void:
	BattlemapSignals.player_input_received.connect(_on_player_input_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_input_signal)
	BattlemapSignals.clear_attack_highlight_tiles.connect(_on_clear_attacked_tiles_signal)
	SpecialSignals.tile_map_status_label_toggled_signal.connect(toggle_tile_status_label_visibility)
	SpecialSignals.highlight_occupied_tiles.connect(toggle_highlight_occupied_tiles)
	status_label.visible = show_status


func toggle_tile_status_label_visibility():
	status_label.visible = not status_label.visible

func toggle_highlight_occupied_tiles():
	_show_if_tile_is_occupied = not _show_if_tile_is_occupied
	_toggle_tile_occuppied_view()

func _toggle_tile_occuppied_view():
	if not _show_if_tile_is_occupied:
		return
	if self.piece_in_tile:
		self.border_color = Color.GREEN
		self.border_width = 3
	else:
		self.border_color = Color.BLACK
		self.border_width = 1

func initialize_tile(
	_border_color: Color,
	x: int, 
	y: int, 
	x_size: int, 
	y_size: int,
	_editor_only: bool = true
):
	_x_position = x
	_y_position = y
	_x_size = x_size
	_y_size = y_size
	
	self.border_color = _border_color
	status_label.text = "(" + str(x) + ", " + str(y) + ")" 
	self.position.x = x * x_size
	self.position.y = y * y_size
	self.editor_only = _editor_only
	self.custom_minimum_size.x = x_size
	self.custom_minimum_size.y = y_size


func show_background():
	background_button.visible = true

func hide_background():
	background_button.visible = false
	
func show_attack_background():
	attack_rect.visible = true
	is_tile_attacked = true

func hide_attack_background():
	attack_rect.visible = false
	is_tile_attacked = false

func show_monster_highlight():
	monster_rect.visible = true

func hide_monster_highlight():
	monster_rect.visible = false

func _toggle_monster_highlight():
	if not is_node_ready():
		return
	if piece_in_tile is MonsterPiece:
		show_monster_highlight()
	else:
		hide_monster_highlight()

func to_vector() -> Vector2:
	return Vector2(_x_position, _y_position)

func _on_player_input_signal():
	self.hide_background()

func add_tile_effect_v2(tile_effect: BaseTileEffectController):
	tile_effects_container.add_child(tile_effect)
	
	## TODO: I should probably read from config
	if self.piece_in_tile:
		tile_effect.apply_effect(piece_in_tile)

func remove_tile_effects():
	for child_effect in tile_effects_container.get_children():
		child_effect.queue_free()

func has_effect() -> bool:
	return tile_effects_container.get_children().size() > 0

func direction_to(_other: Tile) -> Vector2:
	if not _other:
		return Vector2.ZERO
	#return self.to_vector().direction_to(_other.to_vector())
	return (_other.to_vector() - self.to_vector()).normalized()

func is_tile_between_tiles(
	_a_tile: Tile,
	_b_tile: Tile,
	_include_distance_zero: bool = false
) -> bool:
	var _cur_tile_pos: Vector2 = self.to_vector()
	var _a_tile_pos: Vector2 = _a_tile.to_vector()
	var _b_tile_pos: Vector2 = _b_tile.to_vector()
	
	var _a_b_distance: int = MovementUtils.distance_between_tiles(_a_tile, _b_tile)
	var _cur_a_distance: int = MovementUtils.distance_between_tiles(self, _a_tile)
	var _cur_b_distance: int = MovementUtils.distance_between_tiles(self, _b_tile)
	
	if _include_distance_zero and\
		(_cur_a_distance == _a_b_distance or _cur_b_distance == _a_b_distance):
			return true
	
	return _cur_a_distance < _a_b_distance and _cur_b_distance < _a_b_distance

## TODO: needs testing
## Checks if both self and _other tile are in the same general direction to target
func is_in_general_direction_to_other(
	_other: Tile,
	_target: Vector2
) -> bool:
	if not _other:
		return false
	var _self_direction: Vector2 = (self.to_vector() - _target).normalized().ceil()
	var _other_direction: Vector2 = (_other.to_vector() - _target).normalized().ceil()
	if _self_direction == _other_direction:
		return true
	#if (_self_direction.x == 0 or _self_direction.y == 0):
		#if _self_direction.x == 0:
			#return _self_direction.y == _other_direction.y
		#return _self_direction.x == _other_direction.x
	#return false
	return MovementUtils.distance_between_vectors(_self_direction, _other_direction) <= 1

func is_other_opposite_direction_to_self(
	_other: Tile,
	_target: Vector2
) -> bool:
	if not _other:
		return false
	var _s_vector: Vector2 = self.to_vector()
	var _o_vector: Vector2 = _other.to_vector()
	var _self_target_direction: Vector2 = (_s_vector - _target).normalized()
	var _other_self_direction: Vector2 = (_o_vector - _s_vector).normalized()
	#var _target_other_direction: Vector2 = (_o_vector - _s_vector).normalized().ceil()
	var _is_opposite_direction: bool =\
		#MovementUtils.distance_between_vectors(_self_target_direction, _target_other_direction) > 1
		MovementUtils.distance_between_vectors(_self_target_direction, _other_self_direction) > 1
	return _is_opposite_direction

func _on_background_button_pressed() -> void:
	BattlemapSignals.tile_picked_in_battlemap.emit(self)
	hide_background()
	
func trigger_tile_effects(piece: Piece):
	for effect in tile_effects_container.get_children():
		if effect is BaseTileEffectController:
			effect.apply_effect(piece)
	
func _on_clear_attacked_tiles_signal():
	if self.is_tile_attacked:
		hide_attack_background()

func get_center() -> Vector2:
	return Vector2(
		self.position.x - (_x_size/2),
		self.position.y - (_y_size/2)
	)

func is_occupied() -> bool:
	return self.piece_in_tile != null

## TODO: I don't love this but I couldn't figure out how to improve it
func _on_mouse_entered() -> void:
	if not piece_in_tile:
		return
	piece_in_tile.on_mouse_hover_enter()

func _on_mouse_exited() -> void:
	if not piece_in_tile:
		return
	piece_in_tile.on_mouse_hover_exit()
	
func clone() -> Tile:
	var _result: Tile = Tile.new()
	_result._x_position = self._x_position
	_result._y_position = self._y_position
	_result._x_size = self._x_size
	_result._y_size = self._y_size
	_result.is_tile_attacked = self.is_tile_attacked
	_result.piece_in_tile = self.piece_in_tile
	_result._show_if_tile_is_occupied = self._show_if_tile_is_occupied
	return _result
