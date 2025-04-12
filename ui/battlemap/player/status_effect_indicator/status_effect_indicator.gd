extends MarginContainer
class_name StatusEffectIndicator

@onready var description_container: PanelContainer = %DescriptionContainer
@onready var description_label: Label = $HBoxContainer/DescriptionContainer/DescriptionLabel

@export var status_effect: StatusEffect

var _is_hovering: bool = false

func _ready() -> void:
	if status_effect:
		description_label.text = status_effect.description

func _on_texture_rect_mouse_entered() -> void:
	_is_hovering = true
	description_container.visible = true


func _on_texture_rect_mouse_exited() -> void:
	_is_hovering = false
	description_container.visible = false
