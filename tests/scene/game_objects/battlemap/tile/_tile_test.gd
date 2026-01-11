extends Node


func _ready() -> void:
	_run_test(false, _is_in_general_direction_to_other_test_1(), "_is_in_general_direction_to_other_test_1")
	_run_test(true, _is_in_general_direction_to_other_test_2(), "_is_in_general_direction_to_other_test_2")
	_run_test(true, _is_in_general_direction_to_other_test_3(), "_is_in_general_direction_to_other_test_3")
	_run_test(true, _is_in_general_direction_to_other_test_4(), "_is_in_general_direction_to_other_test_4")
	_run_test(true, _is_in_general_direction_to_other_test_5(), "_is_in_general_direction_to_other_test_5")
	_run_test(true, _is_in_general_direction_to_other_test_6(), "_is_in_general_direction_to_other_test_6")

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
