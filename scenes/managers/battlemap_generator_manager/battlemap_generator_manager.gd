extends Node
class_name GenericBattlemap

@export var _center_position_grid: Marker2D

@export var _number_of_columns: int = 6
@export var _number_of_rows: int = 6
@export var _x_tile_size: int = 40
@export var _y_tile_size: int = 40
@export var _spacing_between_grid_elems: float = 10

@export var _debug_mode: bool = true

@onready var grid_array_holder_control: Control = $grid_array_holder_control
@onready var grid_container: GridContainer = $grid_array_holder_control/GridContainer

var grid_array = []

func _ready() -> void:
	_generate_battlemap()
	
func _generate_battlemap():
	print(_generate_battlemap)
	if not _center_position_grid:
		return
	_initialize_grid()
	_populate_grid()

			
func _initialize_grid():
	grid_container.columns = _number_of_columns
	grid_array_holder_control.global_position.x = _center_position_grid.global_position.x - ((_x_tile_size * _number_of_columns) / 2)
	grid_array_holder_control.global_position.y = _center_position_grid.global_position.y - ((_y_tile_size * _number_of_rows) / 2)
	
	
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
