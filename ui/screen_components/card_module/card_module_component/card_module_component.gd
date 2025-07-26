extends Button

## Display info about a card module
class_name CardModuleComponent

signal clicked(card_module: CardModuleComponent)

@onready var card_module_title: Label = %CardModuleTitle
@onready var stamina_cost_label: Label = %StaminaCostLabel

@export var title: String = "Test Title test"
@export var stamina_cost: int = 5
@export var _is_clickable: bool = false

var card_effect: CardEffect

func _ready() -> void:
	set_card_effect(card_effect)
	#if not self.gui_input.is_connected(_on_gui_input):
		#self.gui_input.connect(_on_gui_input)
	
func set_card_effect(
	_card_effect: CardEffect
):
	if not _card_effect:
		return
	card_module_title.text = _card_effect.title
	stamina_cost_label.text = str(_card_effect.stamina_cost)
	self.card_effect = _card_effect.duplicate()

func enable_clicking():
	_is_clickable = true

func disable_clicking():
	_is_clickable = false
	if self.gui_input.is_connected(_on_gui_input):
		self.gui_input.disconnect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if _is_clickable and event.is_pressed():
		clicked.emit(self)


func _on_pressed() -> void:
	if _is_clickable:
		clicked.emit(self)
