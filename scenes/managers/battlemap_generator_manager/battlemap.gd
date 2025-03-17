extends Node
class_name Battlemap

@export var player: Piece
@export var monsters: Array[Piece]

@export var _number_of_columns: int = 6
@export var _number_of_rows: int = 6
@export var _x_tile_size: int = 90
@export var _y_tile_size: int = 90

@export var _debug_mode: bool = true

@onready var grid_array_holder_control: Control = $grid_array_holder_control
@onready var grid_container: GridContainer = $grid_array_holder_control/GridContainer
@onready var _piece_position_manager: PiecePositionManager = $PiecePositionManager

var tile_scene: PackedScene = preload("res://scenes/game_objects/battlemap/tile/tile.tscn")

var grid_array = []

# TODO: It's starting to get too big, need to start thinking about diving this

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

## TODO: we need to export the initial position for player and each monster
func _populate_battlemap():
	_piece_position_manager._player = player
	_piece_position_manager.place_piece_in_tile(player, get_tile(2, 2))
	
	_piece_position_manager.place_piece_in_tile(monsters[0], get_tile(8, 2))
	if monsters.size() > 1:
		_piece_position_manager.place_piece_in_tile(monsters[1], get_tile(7, 2))

func place_piece_in_tile(piece: Piece, tile: Tile):
	_piece_position_manager.place_piece_in_tile(piece, tile)

func place_node_in_tile(node: Node2D, tile: Tile):
	_piece_position_manager.place_node_in_tile(node, tile)

func move_piece_x_right(piece: Piece, x: int) -> void:
	if piece is PlayerCharacter:
		_piece_position_manager.move_player_x_right(x)
	else:
		_piece_position_manager.move_piece_x_right(piece, x)

func get_tile(grix_x, grix_y) -> Tile:
	if grix_x >= 0 && grix_x < _number_of_columns && grix_y >= 0 && grix_y < _number_of_rows:
		return grid_array[grix_y][grix_x]
	return null
