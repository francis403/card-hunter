extends Control
class_name EffectCardModule

@export var card_module_resource: CardModule:
	set(value):
		card_module_resource = value
		if _is_ready:
			_populate_effect_card_module()

@onready var title_label: Label = %TitleLabel
@onready var stamina_label: Label = %StaminaLabel

var _is_ready: bool = false

func _ready() -> void:
	if card_module_resource:
		_populate_effect_card_module()
	_is_ready = true
		
func _populate_effect_card_module():
	title_label.text = card_module_resource.title
	stamina_label.text = str(card_module_resource.stamina_cost)
