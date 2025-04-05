extends Node
class_name GridHighlightManager

@export var battlemap: Battlemap = null

func _ready() -> void:
	BattlemapSignals.clear_highlighted_tiles.connect(_on_clear_highlighted_tiles_signal)
	BattlemapSignals.highlight_tiles.connect(_on_highlight_tiles_signal)
	BattlemapSignals.highlight_move_tiles.connect(_on_hightlight_move_tiles_signal)
	BattlemapSignals.highlight_attack_tiles.connect(_on_highlight_attacked_tiles_signal)

# TODO
func _on_clear_highlighted_tiles_signal():
	pass


func _on_highlight_tiles_signal(
	source_tile: Tile,
	range: int,
	area_type: Constants.AreaType
):
	var config = TileHighlightConfig.new()
	config.area_type = area_type
	config.range = range
	highlight_tiles(source_tile, config)
	
	
## Highlight all movable tiles 
func _on_hightlight_move_tiles_signal(
	source_tile: Tile,
	range: int,
	area_type: Constants.AreaType
):
	var config = TileHighlightConfig.new()
	config.area_type = area_type
	config.range = range
	config.ignore_occupied_tiles = true
	highlight_tiles(source_tile, config)

## Highlights all tiles as attacked
func _on_highlight_attacked_tiles_signal(
	source_tile: Tile,
	range: int,
	area_type: Constants.AreaType
):
	var config = TileHighlightConfig.new()
	config.area_type = area_type
	config.range = range
	config.is_tile_attacked = true
	highlight_tiles(source_tile, config)	

## Highlights all tiles
## TODO: need to pass a tile highlight config object
func highlight_tiles(
	source_tile: Tile,
	config: TileHighlightConfig
):
	var area_type: Constants.AreaType = config.area_type
	if area_type == Constants.AreaType.RADIUS:
		highligh_tiles_radius(
			source_tile,
			config
		)
	elif area_type == Constants.AreaType.CROSS:
		highligh_tiles_cross(
			source_tile,
			config
		)
	elif area_type == Constants.AreaType.SPECIFIC:
		print("TODO: specific movement")
	elif area_type == Constants.AreaType.SHOTGUN:
		print("TODO: shotgun movement")
	elif area_type == Constants.AreaType.LINE:
		highligh_tiles_line(
			source_tile,
			config
		)
	
func highligh_tiles_radius(
	source_tile: Tile,
	config: TileHighlightConfig
):
	var x: int = source_tile._x_position
	var y: int = source_tile._y_position
	var radius = config.range
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var tile_x = x + radius_x
			var tile_y = y + radius_y
			var radius_distance: int = abs(radius_x) + abs(radius_y)
			if config.ignore_origin and radius_distance == 0:
				continue
			if config.ignore_corners and radius_distance > radius:
				continue
			_make_tile_clickable(tile_x, tile_y, config)

func highligh_tiles_cross(
	source_tile: Tile,
	config: TileHighlightConfig
):
	var x = source_tile._x_position
	var y = source_tile._y_position
	var line_length: int = config.range
	for i in range(1, line_length + 1):
		_make_tile_clickable(x + i, y, config)
		_make_tile_clickable(x - i, y, config)
		_make_tile_clickable(x, y + i, config)
		_make_tile_clickable(x, y - i, config)
	
## TODO: this will need the player to hover over where he wants the attack to go
func highligh_tiles_line(
	source_tile: Tile,
	config: TileHighlightConfig
):
	var x = source_tile._x_position
	var y = source_tile._y_position
	var line_length = config.range
	for i in range(1, line_length + 1):
		_make_tile_clickable(x + i, y, config)
	

func _make_tile_clickable(
	x: int,
	y: int,
	config: TileHighlightConfig
):
	var tile: Tile = BattleController.get_tile(x, y)
	var ignore_occupied_tiles: bool = config.ignore_occupied_tiles
	var is_tile_attacked: bool = config.is_tile_attacked
	if not tile:
		return
	if tile.piece_in_tile && ignore_occupied_tiles:
		return
	if tile:
		if is_tile_attacked:
			tile.show_attack_background()
		else:
			tile.show_background()
