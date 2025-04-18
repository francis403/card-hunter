extends Node
class_name StatusEffectContainer

@export var status_effect_ui: StatusEffectUI

func add_status(status: StatusEffect, piece: Piece):
	## TODO: check immunities here maybe
	
	## TODO: not more than one of the same status
	if self.has_status(status.id):
		return
	
	status.target = piece
	self.add_child(status)
	status_effect_ui.add_status_effect_indicator(status)

func has_any_status() -> bool:
	return self.get_child_count() > 0

## TODO: I can improve this with a dictionary
## TODO: Make it O(1) instead of O(n)
func has_status(status_id: String) -> bool:
	for status in self.get_children():
		if status.id == status_id:
			return true
	return false

## TODO: improve this
func remove_status(status_id: String):
	if not status_effect_ui:
		return 
	for child in status_effect_ui.get_status_indicator_children():
		if child.status_effect.id == status_id:
			child.queue_free()
			return
