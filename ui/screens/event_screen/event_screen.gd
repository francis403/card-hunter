extends Screen
class_name EventScreen

signal on_accept_button_pressed_signal(_event_screen: EventScreen)

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var accept_button: Button = %AcceptButton

@export var title_text: String
@export var description_text: String
@export var accept_button_text: String

## TODO: do I need to do this in a different way?
## I can probably do better/smarter
@export var override_accept_button_function: bool = false
@export var accept_button_scene: PackedScene

@export var add_scene_to_parent: bool = true

func _ready() -> void:
	_prep_ui_content()
	
func _prep_ui_content():
	if title_text:
		title.text = title_text
	if description_text:
		description.text = description_text
	if accept_button_text:
		accept_button.text = accept_button_text

func clone(_other: EventScreen):
	self.title_text = _other.title_text
	self.description_text = _other.description_text
	self.accept_button_text = _other.accept_button_text
	self.accept_button_scene = _other.accept_button_scene
	self.override_accept_button_function = _other.override_accept_button_function
	for _con in _other.on_accept_button_pressed_signal.get_connections():
		self.on_accept_button_pressed_signal.connect(_con["callable"])

func _on_accept_button_pressed() -> void:
	on_accept_button_pressed_signal.emit(self)
	if override_accept_button_function:
		return
	if accept_button_scene:
		if not add_scene_to_parent:
			get_tree().change_scene_to_packed(accept_button_scene)
		else:
			self.get_parent().add_child(accept_button_scene.instantiate())
		ScreenUtils.close_event_screen()
	else:
		ScreenUtils.close_event_screen()
