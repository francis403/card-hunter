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
@onready var _grid_highlight_manager: GridHighlightManager = $GridHighlightManager

var tile_scene: PackedScene = preload("res://scenes/game_objects/battlemap/tile/tile.tscn")

var grid_array = []

func clear_highlighted_tiles():
	BattlemapSignals.clear_attack_highlight_tiles.emit()
	
func highlight_tiles(
	source_tile: Tile,
	config: TileHighlightConfig
):
	_grid_highlight_manager.highlight_tiles(source_tile, config)

func highlight_move_tiles(
	source_tile: Tile,
	config: TileHighlightConfig
):
	config.ignore_occupied_tiles = true
	_grid_highlight_manager.highlight_tiles(source_tile, config)

func highlight_attack_tiles(
	source_tile: Tile,
	config: TileHighlightConfig
):
	config.is_tile_attacked = true
	highlight_tiles(source_tile, config)

func get_monster_range_tiles(
	source_tile: Tile,
	config: TileHighlightConfig
):
	config.make_tile_clickable = false
	var result: Array = highlight_tiles(source_tile, config)
	BattlemapSignals.monster_range_tiles_generated.emit(result)

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
			tile.show_status = false
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
	_piece_position_manager.place_piece_in_tile(player, get_tile(2, 2), false)
	
	update_monsters()

func update_monsters():
	if monsters.size() <= 0:
		return
	_piece_position_manager.place_piece_in_tile(monsters[0], get_tile(8, 2), false)
	if monsters.size() > 1:
		_piece_position_manager.place_piece_in_tile(monsters[1], get_tile(7, 2), false)

func place_piece_in_tile(piece: Piece, tile: Tile, animate: bool = true):
	_piece_position_manager.place_piece_in_tile(piece, tile, animate)

func place_node_in_tile(node: Node2D, tile: Tile, animate: bool = true):
	_piece_position_manager.place_node_in_tile(node, tile, animate)

func move_piece_x_right(piece: Piece, x: int) -> void:
	if piece is PlayerCharacter:
		_piece_position_manager.move_player_x_right(x)
	else:
		_piece_position_manager.move_piece_x_right(piece, x)

func get_tile(grix_x, grix_y) -> Tile:
	if grix_x >= 0 && grix_x < _number_of_columns && grix_y >= 0 && grix_y < _number_of_rows:
		return grid_array[grix_y][grix_x]
	return null
	
func get_total_amount_of_monsters():
	return monsters.size()
