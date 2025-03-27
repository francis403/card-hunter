extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_button_pressed"):
		_process_settings_screen()

func _process_settings_screen():
	ScreenUtils.open_settings_screen(get_parent())
	self.process_mode = Node.PROCESS_MODE_ALWAYS
