extends GenericMonster

## A giant monster, which is in more than one tile
class_name GenericGiantMonster

enum GiantMonsterSorroundingTiles {
	FULL_RADIUS,
	HORIZONTAL_LINE,
	VERTICAL_LINE
}

@export var type_of_giant_monster: GiantMonsterSorroundingTiles
@export var extra_size: int = 1

## A giant monster is giant because it has more than one tile.
## The tile in the GenericMonster configuration is the center tile
## This here are the other tiles that the monster is in
var occupying_tiles: Array[Tile]

func _ready() -> void:
	super._ready()
	_set_monster_in_sorrounding_tiles()
	
func _set_monster_in_sorrounding_tiles():
	match type_of_giant_monster:
		GiantMonsterSorroundingTiles.FULL_RADIUS:
			_set_up_radius_tiles()

func _set_up_radius_tiles():
	var x: int = _tile._x_position
	var y: int = _tile._y_position
	var radius: int = extra_size
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var tile_x = x + radius_x
			var tile_y = y + radius_y
			var radius_distance: int = abs(radius_x) + abs(radius_y)
			var furthest_square_distance: int = max(abs(radius_x), abs(radius_y))
			var tile: Tile = BattleController.get_tile(tile_x, tile_y)
			if not tile:
				continue
			tile.piece_in_tile = self
			occupying_tiles.append(tile)

func update_giant_monster_tiles():
	_clear_giant_monster_tiles()
	_set_monster_in_sorrounding_tiles()


func _clear_giant_monster_tiles():
	for tile in occupying_tiles:
		tile.piece_in_tile = null
	occupying_tiles.clear()
