extends MarginContainer
class_name MenuItem

signal menu_item_clicked

@export var _display_name: String = ""

@onready var sound_button: SoundButton = $SoundButton

func _ready() -> void:
	sound_button.pressed_and_sound_played.connect(_on_button_pressed_and_sound_played)
	sound_button.text = _display_name
	
func _on_button_pressed_and_sound_played():
	menu_item_clicked.emit()
	
## Mostly used if the menu item has some content that closes itself.
## Overridable
func close_content():
	pass
