extends Node
class_name Battlemap

@export var player: Piece
@export var monster: Piece

@export var _number_of_columns: int = 6
@export var _number_of_rows: int = 6
@export var _x_tile_size: int = 40
@export var _y_tile_size: int = 40
@export var _spacing_between_grid_elems: float = 10

@export var _debug_mode: bool = true

@onready var grid_array_holder_control: Control = $grid_array_holder_control
@onready var grid_container: GridContainer = $grid_array_holder_control/GridContainer
@onready var piece_position_manager: PiecePositionManager = $PiecePositionManager

var grid_array = []

func _ready() -> void:
	_generate_battlemap()
	_populate_battlemap()
	
func _generate_battlemap():
	print(_generate_battlemap)
	_initialize_grid()
	_populate_grid()
	BattlemapSignals.battlemap_generated.emit(self)

			
func _initialize_grid():
	grid_container.columns = _number_of_columns
	
	
func _populate_grid():
	for i in _number_of_columns:
		grid_array.append([])
		for j in _number_of_rows:
			var tile: ReferenceRect = ReferenceRect.new()
			tile.border_color = Color.BLACK
			tile.position.x = j * self._x_tile_size
			tile.position.y = i * self._y_tile_size
			tile.editor_only = not _debug_mode
			tile.custom_minimum_size.x = _x_tile_size
			tile.custom_minimum_size.y = _y_tile_size
			grid_array[i].append(tile)
			grid_container.add_child(tile)


func _populate_battlemap():
	piece_position_manager._player = player
	player.position = grid_array[0][1].position
	piece_position_manager.place_piece(player, grid_array[2][1].position)
	
	
	piece_position_manager._monster = monster
	piece_position_manager.place_piece(monster, grid_array[0][1].position)
