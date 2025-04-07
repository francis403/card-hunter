extends StatusEffect
class_name StopNextMovements

@export var number_of_movements_to_stop: int = 1

func _ready() -> void:
	#super._ready()
	BattlemapSignals.before_player_movement.connect(apply_effect)
	
## TODO: stop the next movement
## TODO: maybe just set the speed to 0 for the first movement card
func apply_effect():
	print(apply_effect)
