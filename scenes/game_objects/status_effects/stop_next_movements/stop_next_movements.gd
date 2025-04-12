extends StatusEffect
class_name StopNextMovements

@export var number_of_movements_to_stop: int = 1
var old_piece_speed: int = 1

func _ready() -> void:
	## discard next time the monster turn starts
	BattlemapSignals.monster_turn_started.connect(on_effect_discarded)
	old_piece_speed = self.target._speed
	apply_effect()
	
	
## TODO: stop the next movement
## TODO: maybe just set the speed to 0 for the first movement card
func apply_effect():
	self.target._speed = 0
	
func on_effect_discarded():
	self.target._speed = old_piece_speed
	self.target.remove_status(self.id)
	self.queue_free()
