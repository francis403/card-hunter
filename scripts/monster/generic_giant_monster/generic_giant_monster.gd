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
	if not self._tile:
		return
	match type_of_giant_monster:
		GiantMonsterSorroundingTiles.FULL_RADIUS:
			_set_up_radius_tiles()
		GiantMonsterSorroundingTiles.HORIZONTAL_LINE:
			_set_up_horizontal_tiles()
			

func _set_up_radius_tiles():
	var x: int = _tile._x_position
	var y: int = _tile._y_position
	var radius: int = extra_size
	for radius_x in range(-radius, radius + 1):
		for radius_y in range(-radius, radius + 1):
			var tile_x = x + radius_x
			var tile_y = y + radius_y
			var tile: Tile = BattleController.get_tile(tile_x, tile_y)
			if not tile:
				continue
			tile.piece_in_tile = self
			occupying_tiles.append(tile)

## TODO: we need to take into consideration the monster angle
func _set_up_horizontal_tiles():
	var x: int = _tile._x_position
	var y: int = _tile._y_position
	var tile_1: Tile = BattleController.get_tile(x - 1, y)
	if tile_1:
		tile_1.piece_in_tile = self
		occupying_tiles.append(tile_1)
	var tile_2: Tile = BattleController.get_tile(x + 1, y)
	if tile_2:
		tile_2.piece_in_tile = self
		occupying_tiles.append(tile_2)

func update_giant_monster_tiles():
	_clear_giant_monster_tiles()
	_set_monster_in_sorrounding_tiles()


func _clear_giant_monster_tiles():
	for tile in occupying_tiles:
		tile.piece_in_tile = null
	occupying_tiles.clear()

## Returns all tiles this monster would occupy if its center were at center_tile.
## Used to validate movement before committing to a new position.
func get_tiles_at_position(center_tile: Tile) -> Array[Tile]:
	var result: Array[Tile] = []
	if not center_tile:
		return result
	var x: int = center_tile._x_position
	var y: int = center_tile._y_position
	match type_of_giant_monster:
		GiantMonsterSorroundingTiles.FULL_RADIUS:
			for radius_x in range(-extra_size, extra_size + 1):
				for radius_y in range(-extra_size, extra_size + 1):
					var tile: Tile = BattleController.get_tile(x + radius_x, y + radius_y)
					if tile:
						result.append(tile)
		GiantMonsterSorroundingTiles.HORIZONTAL_LINE:
			result.append(center_tile)
			var tile_left: Tile = BattleController.get_tile(x - 1, y)
			if tile_left:
				result.append(tile_left)
			var tile_right: Tile = BattleController.get_tile(x + 1, y)
			if tile_right:
				result.append(tile_right)
	return result

func is_center_position_valid(_center_position: Tile) -> bool:
	for tile in self.get_tiles_at_position(_center_position):
		if tile.piece_in_tile != null and tile.piece_in_tile != self:
			return false
	return true
