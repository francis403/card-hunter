extends Node


func _ready() -> void:
	_run_test(false, _is_in_general_direction_to_other_test_1(), "_is_in_general_direction_to_other_test_1")
	_run_test(true, _is_in_general_direction_to_other_test_2(), "_is_in_general_direction_to_other_test_2")
	_run_test(true, _is_in_general_direction_to_other_test_3(), "_is_in_general_direction_to_other_test_3")
	_run_test(true, _is_in_general_direction_to_other_test_4(), "_is_in_general_direction_to_other_test_4")
	_run_test(true, _is_in_general_direction_to_other_test_5(), "_is_in_general_direction_to_other_test_5")
	_run_test(true, _is_in_general_direction_to_other_test_6(), "_is_in_general_direction_to_other_test_6")
	_run_test(true, _monster_highlight_input_only_is_default(), "_monster_highlight_input_only_is_default")
	_run_test(true, _monster_highlight_shows_in_always_mode_with_monster(), "_monster_highlight_shows_in_always_mode_with_monster")
	_run_test(false, _monster_highlight_shows_in_always_mode_without_monster(), "_monster_highlight_shows_in_always_mode_without_monster")
	_run_test(false, _monster_highlight_hidden_in_input_only_mode_with_monster(), "_monster_highlight_hidden_in_input_only_mode_with_monster")

func _run_test(
	_expected: bool,
	_actual: bool,
	_test_name: String
):
	if _expected != _actual:
		push_error("Error in: ", _test_name)
	else:
		print(_test_name, " ran successfully")

## On the other side it should fail
func _is_in_general_direction_to_other_test_1() -> bool:
	var _tile_1: Tile = Tile.new()
	_tile_1._x_position = 4
	_tile_1._y_position = 2
	var _tile_2: Tile = Tile.new()
	_tile_2._x_position = 0
	_tile_2._y_position = 2
	var _target: Vector2 = Vector2(2, 2)
	return _tile_1.is_in_general_direction_to_other(_tile_2, _target)
	
## directly on the line should be okay
func _is_in_general_direction_to_other_test_2() -> bool:
	var _tile_1: Tile = Tile.new()
	_tile_1._x_position = 4
	_tile_1._y_position = 2
	var _tile_2: Tile = Tile.new()
	_tile_2._x_position = 3
	_tile_2._y_position = 2
	var _target: Vector2 = Vector2(2, 2)
	return _tile_1.is_in_general_direction_to_other(_tile_2, _target)
	
## directly on the line should be okay as long is in the samee direction
func _is_in_general_direction_to_other_test_3() -> bool:
	var _tile_1: Tile = Tile.new()
	_tile_1._x_position = 4
	_tile_1._y_position = 2
	var _tile_2: Tile = Tile.new()
	_tile_2._x_position = 5
	_tile_2._y_position = 2
	var _target: Vector2 = Vector2(2, 2)
	return _tile_1.is_in_general_direction_to_other(_tile_2, _target)
	
## above should be okay too
func _is_in_general_direction_to_other_test_4() -> bool:
	var _tile_1: Tile = Tile.new()
	_tile_1._x_position = 4
	_tile_1._y_position = 2
	var _tile_2: Tile = Tile.new()
	_tile_2._x_position = 4
	_tile_2._y_position = 3
	var _target: Vector2 = Vector2(2, 2)
	return _tile_1.is_in_general_direction_to_other(_tile_2, _target)
	
	
## bellow should be okay too
func _is_in_general_direction_to_other_test_5() -> bool:
	var _tile_1: Tile = Tile.new()
	_tile_1._x_position = 4
	_tile_1._y_position = 2
	var _tile_2: Tile = Tile.new()
	_tile_2._x_position = 3
	_tile_2._y_position = 1
	var _target: Vector2 = Vector2(2, 2)
	return _tile_1.is_in_general_direction_to_other(_tile_2, _target)
	
func _monster_highlight_input_only_is_default() -> bool:
	var _tile: Tile = Tile.new()
	return _tile.highlight_monster_on_player_input_only == true

func _monster_highlight_shows_in_always_mode_with_monster() -> bool:
	var _tile: Tile = Tile.new()
	_tile.highlight_monster_on_player_input_only = false
	_tile.piece_in_tile = MonsterPiece.new()
	return _tile.piece_in_tile is MonsterPiece and not _tile.highlight_monster_on_player_input_only

func _monster_highlight_shows_in_always_mode_without_monster() -> bool:
	var _tile: Tile = Tile.new()
	_tile.highlight_monster_on_player_input_only = false
	return _tile.piece_in_tile is MonsterPiece and not _tile.highlight_monster_on_player_input_only

func _monster_highlight_hidden_in_input_only_mode_with_monster() -> bool:
	var _tile: Tile = Tile.new()
	_tile.highlight_monster_on_player_input_only = true
	_tile.piece_in_tile = MonsterPiece.new()
	return _tile.piece_in_tile is MonsterPiece and not _tile.highlight_monster_on_player_input_only

## bellow should be okay too
func _is_in_general_direction_to_other_test_6() -> bool:
	var _tile_1: Tile = Tile.new()
	_tile_1._x_position = 7.0
	_tile_1._y_position = 3.0
	var _tile_2: Tile = Tile.new()
	_tile_2._x_position = 8.0
	_tile_2._y_position = 2.0
	var _target: Vector2 = Vector2(2.0, 2.0)
	return _tile_1.is_in_general_direction_to_other(_tile_2, _target)
