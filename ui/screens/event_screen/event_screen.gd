extends Screen
class_name EventScreen

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var accept_button: Button = %AcceptButton

@export var title_text: String
@export var description_text: String
@export var accept_button_text: String

## TODO: do I need to do this in a different way?
## I can probably do better/smarter
@export var accept_button_scene: PackedScene


func _ready() -> void:
	_prep_ui_content()
	
	
func _prep_ui_content():
	if title_text:
		title.text = title_text
	if description_text:
		description.text = description_text
	if accept_button_text:
		accept_button.text = accept_button_text

func _on_accept_button_pressed() -> void:
	if accept_button_scene:
		ScreenUtils.close_event_screen()
		get_tree().change_scene_to_packed(accept_button_scene)
