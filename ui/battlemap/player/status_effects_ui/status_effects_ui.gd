extends MarginContainer
class_name StatusEffectUI

const STATUS_EFFECT_INDICATOR_SCENE = preload("res://ui/battlemap/player/status_effect_indicator/status_effect_indicator.tscn")

@onready var h_box_container: HBoxContainer = $HBoxContainer



func add_status_effect_indicator(status: StatusEffect):
	var status_effect_indicator: StatusEffectIndicator = STATUS_EFFECT_INDICATOR_SCENE.instantiate()
	status_effect_indicator.status_effect = status
	h_box_container.add_child(status_effect_indicator)
	
func get_status_indicator_children() -> Array[Node]:
	return h_box_container.get_children()
