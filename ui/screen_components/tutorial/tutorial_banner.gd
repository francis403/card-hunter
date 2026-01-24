extends MarginContainer
class_name TutorialBanner

signal tutorial_completed

@onready var title_label: RichTextLabel = %TitleLabel
@onready var content_label: RichTextLabel = %ContentLabel

@export var title_text: String:
	set(value):
		title_text = value
		if title_label:
			title_label.text = title_text

@export var content_text: String:
	set(value):
		content_text = value
		if content_label:
			content_label.text = content_text

## Array of TextWithIndex resources mapping step indices to rich text content
@export var banner_texts: Array[TextWithIndex] = []

## Array of tooltips to show during the tutorial steps
## Each tooltip corresponds to a step index (0, 1, 2, ...)
@export var tooltips: Array[Tooltip] = []

var _current_index: int = -1
var _is_active: bool = false

func _ready() -> void:
	title_label.text = title_text
	content_label.text = content_text
	_setup_tooltips()

func _input(event: InputEvent) -> void:
	if not _is_active:
		return
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed:
		_on_advance_input()

func _setup_tooltips() -> void:
	for tooltip in tooltips:
		if tooltip:
			tooltip.display_on_hover = false
			tooltip.follow_mouse = false
			tooltip.display_on_mouse_position = false

func get_text_for_index(index: int) -> String:
	for text_item in banner_texts:
		if text_item and text_item.index == index:
			return text_item.text
	return ""

func set_content_for_index(index: int) -> void:
	var text: String = get_text_for_index(index)
	if text:
		content_text = "[center]%s[/center]" % text

func get_tooltip_count() -> int:
	return tooltips.size()

func get_current_index() -> int:
	return _current_index

func show_tooltip_at_index(index: int) -> void:
	if index >= 0 and index < tooltips.size():
		var tooltip: Tooltip = tooltips[index]
		if tooltip:
			tooltip.toggle_on()

func hide_tooltip_at_index(index: int) -> void:
	if index >= 0 and index < tooltips.size():
		var tooltip: Tooltip = tooltips[index]
		if tooltip:
			tooltip.toggle_off()

func advance_step() -> bool:
	## Returns true if there are more steps, false if tutorial is complete
	# Hide current tooltip
	hide_tooltip_at_index(_current_index)
	_current_index += 1
	set_content_for_index(_current_index)
	# Show next tooltip if within bounds
	if _current_index < tooltips.size():
		show_tooltip_at_index(_current_index)
		return true
	return false

func start_tutorial() -> void:
	_current_index = -1
	_is_active = true
	set_content_for_index(_current_index)
	self.visible = true

func is_complete() -> bool:
	return _current_index >= tooltips.size()

func _on_advance_input() -> void:
	var has_more_steps: bool = advance_step()
	if not has_more_steps:
		_finish_tutorial()

func _finish_tutorial() -> void:
	_is_active = false
	_hide_banner()
	tutorial_completed.emit()

func _hide_banner() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): self.visible = false)

func add_tooltip(tooltip: Tooltip) -> void:
	if tooltip:
		tooltip.display_on_hover = false
		tooltip.follow_mouse = false
		tooltip.display_on_mouse_position = false
		tooltips.append(tooltip)

func insert_tooltip_at(index: int, tooltip: Tooltip) -> void:
	if tooltip:
		tooltip.display_on_hover = false
		tooltip.follow_mouse = false
		tooltip.display_on_mouse_position = false
		tooltips.insert(index, tooltip)
