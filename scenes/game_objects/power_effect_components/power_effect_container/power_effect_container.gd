extends Node
class_name PowerEffectContainer

@export var power_effect_ui: PowerEffectUI

func add_power_effect(power_effect: BasePowerNodeController, piece: Piece):
	if self.has_power_effect(power_effect.power_effect_resource.id):
		return
	
	#power_effect.target = piece
	if not power_effect._power_holder_piece:
		power_effect._power_holder_piece = piece
	self.add_child(power_effect)
	power_effect_ui.add_power_effect_indicator(power_effect)

func has_any_power_effect() -> bool:
	return self.get_child_count() > 0

## TODO: I can improve this with a dictionary
## TODO: Make it O(1) instead of O(n)
func has_power_effect(power_effect_id: String) -> bool:
	for power_effect in self.get_children():
		if power_effect.get_id() == power_effect_id:
			return true
	return false

## TODO: improve this
func remove_power_effect(status_id: String):
	if not power_effect_ui:
		return 
	for child in power_effect_ui.get_power_effect_indicator_children():
		if child.power_effect.id == status_id:
			child.queue_free()
			return

func remove_all_power_effects():
	for child in power_effect_ui.get_power_effect_indicator_children():
		child.queue_free()
