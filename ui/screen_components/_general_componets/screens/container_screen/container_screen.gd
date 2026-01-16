extends PanelContainer

## A screen that is only supposed to take a small part of the screen. Usually center stage.
## - Any SoundButton will be put into the HBox Button Container
## - Comes with one button by default to close the container, which can be hidden
class_name ContainerScreen

signal on_container_button_clicked(_button: SoundButton)

@export var title: String
@export_multiline var description: String
@export var hide_default_button: bool = false

@onready var title_label: Label = %Title
@onready var description_label: Label = %Description
@onready var button_container: MarginContainer = $MarginContainer2/VBoxContainer/ButtonContainer
@onready var close_button: SoundButton = $MarginContainer2/VBoxContainer/ButtonContainer/HBoxButtonContainer/CloseButton
@onready var h_box_button_container: HBoxContainer = %HBoxButtonContainer

@export_group("Button Container Configuration")
@export var separation: int = 15

func _ready() -> void:
	_process_basic_parameters()
	_process_button_container_configurations()
	_process_child_nodes()
	
func _process_basic_parameters():
	title_label.text = title
	description_label.text = description
	close_button.visible = not hide_default_button

func _process_button_container_configurations():
	h_box_button_container.add_theme_constant_override("separation", separation)

func _process_child_nodes():
	for _child in self.get_children():
		if _child is SoundButton:
			if _child.get_parent():
				self.remove_child(_child)
			h_box_button_container.add_child(_child, 0)
			
func _on_button_clicked_signal():
	on_container_button_clicked.emit()
