extends MarginContainer

## Represents the power effects on the player
class_name PowerEffectUI

const POWER_EFFECT_INDICATOR = preload("res://ui/battlemap/player/power_effect_indicator/power_effect_indicator.tscn")

@onready var h_box_container: HBoxContainer = $HBoxContainer

func add_power_effect_indicator(power_effect: BasePowerNodeController):
	var power_effect_indicator: PowerEffectIndicator = POWER_EFFECT_INDICATOR.instantiate()
	power_effect_indicator.power_effect = power_effect.power_effect_resource
	h_box_container.add_child(power_effect_indicator)
	
func get_power_effect_indicator_children() -> Array[Node]:
	return h_box_container.get_children()

## TODO: this can be faster
func remove_power_effect(status_id: String):
	for child in h_box_container.get_children():
		if child.status_effect.id == status_id:
			child.queue_free()
			return
