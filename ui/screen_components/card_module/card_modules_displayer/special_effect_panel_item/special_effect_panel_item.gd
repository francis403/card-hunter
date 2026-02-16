extends PanelContainer
class_name SpecialEffectPanelItem

signal close_pressed(item: SpecialEffectPanelItem)

@onready var trigger_label: Label = %TriggerLabel
@onready var title_label: Label = %TitleLabel
@onready var close_button: Button = %CloseButton

var _special_effect: SpecialCardEffectResource

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	close_button.visible = false

func set_special_effect(effect: SpecialCardEffectResource) -> void:
	_special_effect = effect
	if trigger_label:
		trigger_label.text = effect.get_trigger_label()
	if title_label:
		title_label.text = effect.title

func get_special_effect() -> SpecialCardEffectResource:
	return _special_effect

func toggle_close_button(_is_visible: bool) -> void:
	if close_button:
		close_button.visible = _is_visible

func _on_close_button_pressed() -> void:
	close_pressed.emit(self)
