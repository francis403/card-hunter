extends Node
class_name Battlemap

@export var player: Piece
@export var monster: Piece

@export var _number_of_columns: int = 6
@export var _number_of_rows: int = 6
@export var _x_tile_size: int = 90
@export var _y_tile_size: int = 90
@export var _spacing_between_grid_elems: float = 10

@export var _debug_mode: bool = true

@onready var grid_array_holder_control: Control = $grid_array_holder_control
@onready var grid_container: GridContainer = $grid_array_holder_control/GridContainer
@onready var piece_position_manager: PiecePositionManager = $PiecePositionManager

var tile_scene: PackedScene = preload("res://scenes/game_objects/battlemap/tile/tile.tscn")

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
	for grid_y in _number_of_rows:
		grid_array.append([])
		for grid_x in _number_of_columns:
			var tile: Tile = tile_scene.instantiate()
			tile.show_status = true
			grid_container.add_child(tile)
			tile.initialize_tile(
				Color.BLACK,
				grid_x, 
				grid_y,
				_x_tile_size,
				_y_tile_size,
				not _debug_mode
			)
			grid_array[grid_y].append(tile)

func _populate_battlemap():
	piece_position_manager._player = player
	#var player_position: Vector2 = grid_array[0][0].global_position
	#player_position.x += _x_tile_size / 2
	#player_position.y += _y_tile_size / 2
	piece_position_manager.place_piece_in_tile(player, get_tile(0, 0))
	
	piece_position_manager._monster = monster
	piece_position_manager.place_piece_in_tile(monster, get_tile(9, 2))

func get_tile(grix_x, grix_y) -> Tile:
	return grid_array[grix_y][grix_x]
