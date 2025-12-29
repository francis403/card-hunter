extends Resource

## Is a formula to be used to create more complex patterns.
## (0, 0) is the origin tile, and (0, 1) will be the tile up from the origin tile
## Available variables:
## x -> relative x position to origin tile
## y -> relative y position to origin tile
## p_x -> player_x relative to origin tile
## p_y -> player_y relative to origin tile
## m_x -> monster_x relative to origin tile
## m_y -> monster_y relative to origin tile
class_name Formula

## Formula can be like y == x + 1
@export_custom(PROPERTY_HINT_EXPRESSION, "")
var _formula: String

var _expression: Expression

func _init():
	_expression = Expression.new()
	
func is_point_in_formula(
	_relative_point: Vector2,
	_relative_player_position: Vector2
) -> bool:
	var inputs = {
		"x": _relative_point.x,
		"y": _relative_point.y,
		"p_x": _relative_player_position.x,
		"p_y": _relative_player_position.y,
		"m_x": _relative_player_position.x,
		"m_y": _relative_player_position.y,
	}
	var _result = _expression.parse(_formula, inputs.keys())
	
	if _result != OK:
		push_warning("Expression parse error: ", _expression.get_error_text())
		return false
		
	_result = _expression.execute(inputs.values())
	
	if _expression.has_execute_failed():
		push_warning("Formula parse error: " + _expression.get_error_text())
		return false
	#print("Expression result: %s for point %s" % [_result, _relative_point])
	
	#return bool(_result) if _result != null else false
	return _result
