extends PanelContainer

## A screen that is only supposed to take a small part of the screen. Usually center stage
class_name ClassDescriptionSubscreen

signal on_container_button_clicked

@export_group("Player Class to display")
@export var player_class: PlayerClass

@export_group("Description Config")
@export var show_description: bool = true
@export_multiline var description: String

@export_group("Button Configuration")
@export var show_button: bool = true
@export var button_text: String

@onready var sound_button: SoundButton = $MarginContainer2/VBoxContainer/MarginContainer/SoundButton
@onready var class_description: Label = %ClassDescription
@onready var class_picker_component: ClassPickerComponent = $MarginContainer2/VBoxContainer/ClassPickerComponent

func _ready() -> void:
	sound_button.pressed_and_sound_played.connect(_on_button_clicked_signal)
	reload_ui()
	
func reload_ui():
	sound_button.visible = self.show_button
	sound_button.text = self.button_text
	class_description.visible = self.show_description
	if player_class:
		_update_ui_fields_with_player_class_info()
	
func _update_ui_fields_with_player_class_info():
	class_description.text = player_class.description
	class_picker_component.update_ui(player_class)
	
	
func _on_button_clicked_signal():
	on_container_button_clicked.emit()
