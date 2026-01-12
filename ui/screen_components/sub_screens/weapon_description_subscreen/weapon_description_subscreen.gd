extends PanelContainer

## A screen that is only supposed to take a small part of the screen. Usually center stage
class_name ClassDescriptionSubscreen

signal on_container_button_clicked
signal on_cards_preview_button_clicked

@export_group("Player Class to display")
@export var player_class: PlayerClass

@export_group("Description Config")
@export var show_description: bool = true
@export_multiline var description: String

@export_group("Button Configuration")
@export var show_button: bool = true
@export var button_text: String

@onready var main_button: SoundButton = %MainButton
@onready var card_preview: SoundButton = $MarginContainer2/VBoxContainer/MarginContainer/VBoxContainer/CardPreview
@onready var class_description: Label = %ClassDescription
@onready var class_picker_component: ClassPickerComponent = $MarginContainer2/VBoxContainer/ClassPickerComponent

func _ready() -> void:
	main_button.pressed_and_sound_played.connect(_on_button_clicked_signal)
	card_preview.pressed_and_sound_played.connect(_on_card_preview_button_clicked)
	reload_ui()
	
func reload_ui():
	main_button.visible = self.show_button
	main_button.text = self.button_text
	class_description.visible = self.show_description
	if player_class:
		_update_ui_fields_with_player_class_info()
	
func _update_ui_fields_with_player_class_info():
	class_description.text = player_class.description
	class_picker_component.update_ui(player_class)
	
func _on_button_clicked_signal():
	on_container_button_clicked.emit()
	
func _on_card_preview_button_clicked():
	on_cards_preview_button_clicked.emit()
