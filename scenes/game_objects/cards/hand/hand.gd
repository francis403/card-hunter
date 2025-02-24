extends Control


func _ready() -> void:
	BattlemapSignals.awaiting_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.canceled_player_input.connect(_on_input_received_signal)
	BattlemapSignals.player_input_received.connect(_on_input_received_signal)
	BattlemapSignals.lock_player_input.connect(_on_input_awaiting_signal)
	BattlemapSignals.unlock_player_input.connect(_on_input_received_signal)


func _on_input_awaiting_signal():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _on_input_received_signal():
	self.process_mode = Node.PROCESS_MODE_INHERIT
