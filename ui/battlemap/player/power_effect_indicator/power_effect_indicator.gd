extends MarginContainer
class_name PowerEffectIndicator

@onready var description_container: PanelContainer = %DescriptionContainer
@onready var description_label: Label = $HBoxContainer/DescriptionContainer/DescriptionLabel

@export var power_effect: PowerEffect

var _is_hovering: bool = false

func _ready() -> void:
	if power_effect:
		description_label.text = power_effect.description

func _on_texture_rect_mouse_entered() -> void:
	_is_hovering = true
	description_container.visible = true


func _on_texture_rect_mouse_exited() -> void:
	_is_hovering = false
	description_container.visible = false
