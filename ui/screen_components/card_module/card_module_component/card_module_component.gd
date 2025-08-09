extends Button

## Display info about a card module
class_name CardModuleComponent

signal clicked(card_module: CardModuleComponent)

@onready var card_module_title: Label = %CardModuleTitle
@onready var stamina_cost_label: Label = %StaminaCostLabel
@onready var description: RichTextLabel = %MainDescription
@onready var top_section: PanelContainer = %TopSection
@onready var bottom_section: PanelContainer = %BottomSection


@export var title: String = "Test Title test"
@export var stamina_cost: int = 5
@export var _is_clickable: bool = false

## TODO: A card module also needs to have some limitations

var card_module: CardModule

func _ready() -> void:
	set_card_module(card_module)
	self.pressed.connect(_on_pressed)
	
func set_card_module(
	_card_module: CardModule
):
	if not _card_module:
		return
	card_module_title.text = _card_module.title
	stamina_cost_label.text = str(_card_module.stamina_cost)
	self.card_module = _card_module.duplicate()
	self._change_color_based_on_type()

func _change_color_based_on_type():
	if not card_module:
		return
	var top_style_box = top_section.get_theme_stylebox("panel").duplicate()
	var bottom_style_box = bottom_section.get_theme_stylebox("panel").duplicate()
	
	top_style_box.set("bg_color", card_module.get_top_section_color())
	top_section.add_theme_stylebox_override("panel", top_style_box)
	bottom_style_box.set("bg_color", card_module.get_bottom_section_color())
	bottom_section.add_theme_stylebox_override("panel", bottom_style_box)

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
