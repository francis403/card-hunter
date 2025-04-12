extends StatusEffect
class_name DoubleSpeedStatusEffect

@export var number_of_turns: int = 2

var old_piece_speed: int = 1
var _turn_count: int = 0

func _ready() -> void:
	## discard next time the monster turn starts
	BattlemapSignals.monster_turn_started.connect(_on_monster_turn_started)
	old_piece_speed = self.target._speed
	if self.status_effect_config:	
		number_of_turns = status_effect_config.number_of_turns
	apply_effect()
	
func _on_monster_turn_started():
	_turn_count += 1
	if _turn_count >= number_of_turns:
		self.on_effect_discarded()
	
## TODO: stop the next movement
## TODO: maybe just set the speed to 0 for the first movement card
func apply_effect():
	self.target._speed *= 2
	
func on_effect_discarded():
	self.target._speed = old_piece_speed
	self.target.remove_status(self.id)
	self.queue_free()
