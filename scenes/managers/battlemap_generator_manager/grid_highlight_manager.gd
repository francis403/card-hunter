extends Node
class_name GridHighlightManager

@export var battlemap: Battlemap = null

func _ready() -> void:
	BattlemapSignals.clear_highlighted_tiles.connect(_on_clear_highlighted_tiles_signal)
	BattlemapSignals.highlight_tiles.connect(_on_highlight_tiles_signal)
	BattlemapSignals.highlight_move_tiles.connect(_on_hightlight_move_tiles_signal)
	##BattlemapSignals.highlight_attack_tiles.connect(_on_highlight_attacked_tiles_signal)
	BattlemapSignals.get_monster_range_tiles.connect(_on_get_monster_range_tiles_signal)
	
# TODO
func _on_clear_highlighted_tiles_signal():
	pass


func _on_highlight_tiles_signal(
	source_tile: Tile,
	config: TileHighlightConfig
):
	highlight_tiles(source_tile, config)
	
	
## Highlight all movable tiles 
func _on_hightlight_move_tiles_signal(
	source_tile: Tile,
	config: TileHighlightConfig
):
	config.ignore_occupied_tiles = true
	highlight_tiles(source_tile, config)

## Highlights all tiles as attacked
func _on_highlight_attacked_tiles_signal(
	source_tile: Tile,
	config: TileHighlightConfig
):
	config.is_tile_attacked = true
	highlight_tiles(source_tile, config)

func _on_get_monster_range_tiles_signal(
	source_tile: Tile,
	config: TileHighlightConfig
):
	config.make_tile_clickable = false
	var result: Array = highlight_tiles(source_tile, config)
	BattlemapSignals.monster_range_tiles_generated.emit(result)

## Highlights all tiles
func highlight_tiles(
	source_tile: Tile,
	config: TileHighlightConfig
) -> Array[Tile]:
	if not config:
		return []
	var highlighted_tiles: Array[Tile] = []
	var area_type: Constants.AreaType = config.area_type
	if area_type == Constants.AreaType.RADIUS\
		or area_type == Constants.AreaType.INHERIT:
		highlighted_tiles.append_array(
			highligh_tiles_radius(
				source_tile,
				config
			)
		)
	elif area_type == Constants.AreaType.CROSS:
		highligh_tiles_cross(
			source_tile,
			config
		)
	elif area_type == Constants.AreaType.SPECIFIC:
		highligh_tile_specific(
			source_tile,
			config
		)
	elif area_type == Constants.AreaType.SHOTGUN:
		print("TODO: shotgun movement")
	elif area_type == Constants.AreaType.LINE:
		highligh_tiles_line(
			source_tile,
			config
		)
	return highlighted_tiles

## TODO: can I put this into a utils function of some sort?
## we can maybe add a callable here as an argument
func highligh_tiles_radius(
	source_tile: Tile,
	config: TileHighlightConfig
) -> Array[Tile]:
	var highlighted_tiles: Array[Tile] = []
	var x: int = source_tile._x_position
	var y: int = source_tile._y_position
	var radius = config._range
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var _tile_x = x + radius_x
			var _tile_y = y + radius_y
			var _tile: Tile = BattleController.get_tile(_tile_x, _tile_y)
			if not config.is_tile_valid(
				source_tile,
				Vector2(radius_x, radius_y)
			):
				continue
			highlighted_tiles.append(_tile)
			_make_tile_clickable(_tile_x, _tile_y, config)
	return highlighted_tiles

func highligh_tiles_cross(
	source_tile: Tile,
	config: TileHighlightConfig
):
	var x = source_tile._x_position
	var y = source_tile._y_position
	var line_length: int = config._range
	for i in range(1, line_length + 1):
		if not config.ignore_north_tiles:
			_make_tile_clickable(x, y - i, config)
		if not config.ignore_south_tiles:
			_make_tile_clickable(x, y + i, config)
		if not config.ignore_east_tiles:
			_make_tile_clickable(x + i, y, config)
		if not config.ignore_west_tiles:
			_make_tile_clickable(x - i, y, config)
	
## TODO: this will need the player to hover over where he wants the attack to go
func highligh_tiles_line(
	source_tile: Tile,
	config: TileHighlightConfig
):
	var x = source_tile._x_position
	var y = source_tile._y_position
	var line_length = config._range
	for i in range(1, line_length + 1):
		_make_tile_clickable(x + i, y, config)

func highligh_tile_specific(
	source_tile: Tile,
	config: TileHighlightConfig
):
	_make_tile_clickable(source_tile._x_position, source_tile._y_position, config)

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
		elif config.make_tile_clickable:
			tile.show_background()
