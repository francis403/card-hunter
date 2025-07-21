extends Control

## Display info about a card module
class_name CardModuleComponent

signal clicked(card_module: CardModuleComponent)

@onready var card_module_title: Label = %CardModuleTitle
@onready var stamina_cost_label: Label = %StaminaCostLabel

@export var title: String = "Test Title test"
@export var stamina_cost: int = 5
@export var _is_clickable: bool = false

func _ready() -> void:
	set_card_fields(title, stamina_cost)
	if _is_clickable:
		self.gui_input.connect(_on_gui_input)
	
func set_card_fields(
	_title: String,
	_stamina_cost: int
):
	card_module_title.text = _title
	stamina_cost_label.text = str(_stamina_cost)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		clicked.emit()
		
