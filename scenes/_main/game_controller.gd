extends Node
class_name GameController


func _ready() -> void:
	pass
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_button_pressed"):
		BattlemapSignals.canceled_player_input.emit()
