extends Node
class_name GridHighlightManager

@export var battlemap: Battlemap = null

func _ready() -> void:
	BattlemapSignals.clear_highlighted_tiles.connect(_on_clear_highlighted_tiles_signal)
	BattlemapSignals.highlight_tiles.connect(_on_highlight_tiles_signal)
	BattlemapSignals.highlight_attack_tiles.connect(_on_highlight_attacked_tiles_signal)

# TODO
func _on_clear_highlighted_tiles_signal():
	pass


func _on_highlight_tiles_signal(
	source_tile: Tile,
	range: int,
	area_type: Constants.AreaType
):
	highlight_tiles(source_tile, range, area_type)
	
func _on_highlight_attacked_tiles_signal(
	source_tile: Tile,
	range: int,
	area_type: Constants.AreaType
):
	highlight_tiles(source_tile, range, area_type, true)	

func highlight_tiles(
	source_tile: Tile,
	range: int,
	area_type: Constants.AreaType,
	is_tile_attacked: bool = false
):
	if area_type == Constants.AreaType.RADIUS:
		highligh_tiles_radius(
			source_tile,
			range,
			is_tile_attacked
		)
	elif area_type == Constants.AreaType.CROSS:
		highligh_tiles_cross(
			source_tile,
			range
		)
	elif area_type == Constants.AreaType.SPECIFIC:
		print("TODO: specific movement")
	elif area_type == Constants.AreaType.SHOTGUN:
		print("TODO: shotgun movement")

# TODO: how can I do this well?
func highligh_tiles_radius(source_tile: Tile, radius: int, is_tile_attacked: bool = false):
	var x = source_tile._x_position
	var y = source_tile._y_position
	_make_tile_clickable(x + 1, y, is_tile_attacked)
	_make_tile_clickable(x - 1, y, is_tile_attacked)
	_make_tile_clickable(x, y + 1, is_tile_attacked)
	_make_tile_clickable(x, y - 1, is_tile_attacked)
	_make_tile_clickable(x - 1, y - 1, is_tile_attacked)	
	_make_tile_clickable(x + 1, y + 1, is_tile_attacked)
	_make_tile_clickable(x - 1, y + 1, is_tile_attacked)
	_make_tile_clickable(x + 1, y - 1, is_tile_attacked)
	
func highligh_tiles_cross(source_tile: Tile, line_length: int):
	var x = source_tile._x_position
	var y = source_tile._y_position
	for i in range(1, line_length + 1):
		_make_tile_clickable(x + i, y)
		_make_tile_clickable(x - i, y)
		_make_tile_clickable(x, y + i)
		_make_tile_clickable(x, y - i)
	
func _make_tile_clickable(x: int, y: int, is_tile_attacked: bool = false):
	var tile: Tile = BattleController.get_tile(x, y)
	if tile:
		if is_tile_attacked:
			tile.show_attack_background()
		else:
			tile.show_background()
