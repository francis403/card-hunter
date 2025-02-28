extends ReferenceRect
class_name Tile


var _x_position: int
var _y_position: int
var _x_size: int = 40
var _y_size: int = 40
var is_tile_attacked: bool = false

@export var show_status: bool = false

@onready var background_button: Button = $BackgroundButton
@onready var status_label: Label = $StatusLabel
@onready var attack_rect: ColorRect = $AttackRect

var piece_in_tile: Piece = null

func _ready() -> void:
	BattlemapSignals.player_input_received.connect(_on_player_input_signal)
	BattlemapSignals.canceled_player_input.connect(_on_player_input_signal)
	BattlemapSignals.clear_player_highlighted_tiles.connect(_on_player_input_signal)
	BattlemapSignals.clear_attack_highlight_tiles.connect(_on_clear_attacked_tiles_signal)
	
	status_label.visible = show_status


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

func _on_player_input_signal():
	self.hide_background()

func _on_background_button_pressed() -> void:
	BattlemapSignals.tile_picked_in_battlemap.emit(self)
	hide_background()
	
func _on_clear_attacked_tiles_signal():
	if self.is_tile_attacked:
		hide_attack_background()
