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
	for i in _number_of_columns:
		grid_array.append([])
		for j in _number_of_rows:
			var tile: Tile = tile_scene.instantiate()
			#tile.border_color = Color.BLACK
			#tile.position.x = j * self._x_tile_size
			#tile.position.y = i * self._y_tile_size
			#tile.editor_only = not _debug_mode
			#tile.custom_minimum_size.x = _x_tile_size
			#tile.custom_minimum_size.y = _y_tile_size
			tile.show_status = true
			grid_container.add_child(tile)
			tile.initialize_tile(
				Color.BLACK,
				j, 
				i,
				_x_tile_size,
				_y_tile_size,
				not _debug_mode
			)
			grid_array[i].append(tile)


func _populate_battlemap():
	piece_position_manager._player = player
	#var player_position: Vector2 = grid_array[0][0].global_position
	#player_position.x += _x_tile_size / 2
	#player_position.y += _y_tile_size / 2
	piece_position_manager.place_piece_in_tile(player, grid_array[0][0])
	
	piece_position_manager._monster = monster
	piece_position_manager.place_piece_in_tile(monster, grid_array[0][3])
