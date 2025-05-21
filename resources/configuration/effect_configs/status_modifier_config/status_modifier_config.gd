extends Resource

## This can be applied to:
## Pieces
class_name StatusModifierConfig

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

@export var stat: Constants.StatType
@export var operation: Operation
@export var value: float = 1.0


func get_changed_value(stat_value: int) -> int:
	match operation:
		Operation.ADD:
			return stat_value + value
		Operation.SUBTRACT:
			return stat_value - value 
		Operation.MULTIPLY:
			return stat_value * value  
		Operation.DIVIDE:
			return stat_value / value 
	return stat_value

func apply_status_change(piece: Piece):
	var modified_stat_value: int = 0
	match stat:
		Constants.StatType.STAMINA:
			modified_stat_value = get_changed_value(piece._stamina)
			piece._stamina = clamp(modified_stat_value, 0, piece._stamina)
			if piece is PlayerPiece:
				BattlemapSignals.player_stamina_changed.emit(piece._health)
		Constants.StatType.HEALTH:
			modified_stat_value = get_changed_value(piece._health)
			piece._health = clamp(modified_stat_value, 0, piece._max_hp)
			if piece is PlayerPiece:
				BattlemapSignals.player_health_changed.emit(piece._health)
	return
