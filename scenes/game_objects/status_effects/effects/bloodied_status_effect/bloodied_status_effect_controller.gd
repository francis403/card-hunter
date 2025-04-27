extends GenericStatusEffectController

## For now being bloodied means the monsters deal more damage to you
## TODO: ideally it would mean that other things can happen as well
class_name BloodiedStatusEffect

@export var damage_multipler: float = 1.5

var effect_triggered: bool = false

func _ready():
	super._ready()
	target.piece_took_damage.connect(_on_piece_damaged_signal)

func _on_piece_damaged_signal(damage: int):
	print(_on_piece_damaged_signal)
	if effect_triggered:
		return
	effect_triggered = true
	var damage_dealt: int = damage * (damage_multipler - 1)
	target.apply_damage(damage_dealt)
	on_effect_discarded()
	
#func on_effect_discarded():
	#self.target.remove_status(self.id)
	#self.queue_free()
