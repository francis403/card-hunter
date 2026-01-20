extends Resource
class_name EventConfig

@export var title: String
@export_multiline var description: String
@export var accept_button_text: String
@export var buttons: Array[EventButtonConfig] = []

func get_button_configs() -> Array[EventButtonConfig]:
	if not buttons.is_empty():
		return buttons
	# Fallback to accept_button_text for backward compatibility
	if accept_button_text != "":
		var legacy := EventButtonConfig.new()
		legacy.button_text = accept_button_text
		legacy.action = CloseEventButtonAction.new()
		return [legacy]
	return []
