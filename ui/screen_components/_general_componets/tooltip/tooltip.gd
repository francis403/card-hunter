extends PanelContainer
class_name Tooltip


enum TooltipPosition {
	AUTO,
	ABOVE,
	BELOW,
	LEFT,
	RIGHT
}

@export_multiline var display_text: String
@export var show_delay: float = AnimationConstants.TOOLTIP_DEFAULT_DELAY
@export var position_offset: Vector2 = Vector2(10, 10)
@export var preferred_position: TooltipPosition = TooltipPosition.AUTO
@export var follow_mouse: bool = true

@export_group("Visibility Configuration")
@export var display_on_hover: bool = true
@export var display_on_mouse_position: bool = true

@onready var content_rich_text_label: RichTextLabel = %ContentRichTextLabel

var _delay_timer: Timer
var _show_tween: Tween
var _parent_control: Control = null

func _ready() -> void:
	_setup_timer()
	_setup_container()
	call_deferred("_connect_parent_signals")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_position()

func _setup_timer() -> void:
	_delay_timer = Timer.new()
	_delay_timer.one_shot = true
	_delay_timer.timeout.connect(_on_delay_timeout)
	add_child(_delay_timer)

func _setup_container() -> void:
	self.visible = false
	self.modulate.a = 0.0
	self.scale = Vector2(0.8, 0.8)
	set_process_input(false)
	_update_content()


func _connect_parent_signals() -> void:
	var parent: Node = get_parent()
	if parent is Control:
		_parent_control = parent
		if not _parent_control.mouse_entered.is_connected(_on_parent_mouse_entered):
			_parent_control.mouse_entered.connect(_on_parent_mouse_entered)
		if not _parent_control.mouse_exited.is_connected(_on_parent_mouse_exited):
			_parent_control.mouse_exited.connect(_on_parent_mouse_exited)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			call_deferred("_connect_parent_signals")
		NOTIFICATION_UNPARENTED:
			_disconnect_parent_signals()


func _disconnect_parent_signals() -> void:
	if _parent_control:
		if _parent_control.mouse_entered.is_connected(_on_parent_mouse_entered):
			_parent_control.mouse_entered.disconnect(_on_parent_mouse_entered)
		if _parent_control.mouse_exited.is_connected(_on_parent_mouse_exited):
			_parent_control.mouse_exited.disconnect(_on_parent_mouse_exited)
		_parent_control = null

func _update_content() -> void:
	if content_rich_text_label:
		# Pass display_text through tr() so that translation keys (e.g. "UI_IN_DEVELOPMENT")
		# are resolved at display time using the current locale.  Plain-English strings that
		# are not registered keys are returned unchanged by tr(), so this is backward-compatible
		# with any existing callers that assign raw text directly.
		content_rich_text_label.text = tr(self.display_text)


func _update_position() -> void:
	var _parent: Node = get_parent()
	var mouse_pos: Vector2 = Vector2.ZERO
	if display_on_mouse_position:
		mouse_pos = get_viewport().get_mouse_position()
	elif _parent is Node2D or _parent is Control:
		mouse_pos = _parent.global_position
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var tooltip_size: Vector2 = self.size
	var final_pos: Vector2 = mouse_pos + position_offset

	match preferred_position:
		TooltipPosition.ABOVE:
			final_pos = mouse_pos - Vector2(tooltip_size.x / 2, tooltip_size.y + position_offset.y)
		TooltipPosition.BELOW:
			final_pos = mouse_pos + Vector2(-tooltip_size.x / 2, position_offset.y)
		TooltipPosition.LEFT:
			final_pos = mouse_pos - Vector2(tooltip_size.x + position_offset.x, tooltip_size.y / 2)
		TooltipPosition.RIGHT:
			final_pos = mouse_pos + Vector2(position_offset.x, -tooltip_size.y / 2)
		TooltipPosition.AUTO, _:
			final_pos = mouse_pos + position_offset

	# Clamp to screen bounds
	var margin = 5.0
	final_pos.x = clamp(final_pos.x, margin, viewport_size.x - tooltip_size.x - margin)
	final_pos.y = clamp(final_pos.y, margin, viewport_size.y - tooltip_size.y - margin)

	self.global_position = final_pos


func _on_parent_mouse_entered() -> void:
	if not display_on_hover:
		return
	_delay_timer.start(show_delay)


func _on_parent_mouse_exited() -> void:
	if not display_on_hover:
		return
	_delay_timer.stop()
	toggle_off()


func _on_delay_timeout() -> void:
	toggle_on()


func toggle_on() -> void:
	if not display_text:
		return

	# _update_content resolves tr() at the moment the tooltip is shown,
	# so language switches are automatically reflected on next hover.
	_update_content()

	if _show_tween:
		_show_tween.kill()

	self.visible = true
	set_process_input(follow_mouse)
	_update_position()

	_show_tween = create_tween()
	_show_tween.set_parallel(true)
	_show_tween.set_ease(Tween.EASE_OUT)
	_show_tween.set_trans(Tween.TRANS_BACK)
	_show_tween.tween_property(self, "modulate:a", 1.0, AnimationConstants.TOOLTIP_SHOW_DURATION)
	_show_tween.tween_property(self, "scale", Vector2.ONE, AnimationConstants.TOOLTIP_SHOW_DURATION)


func toggle_off() -> void:
	if not visible:
		return

	set_process_input(false)

	if _show_tween:
		_show_tween.kill()

	_show_tween = create_tween()
	_show_tween.set_parallel(true)
	_show_tween.set_ease(Tween.EASE_IN)
	_show_tween.set_trans(Tween.TRANS_QUAD)
	_show_tween.tween_property(self, "modulate:a", 0.0, AnimationConstants.TOOLTIP_HIDE_DURATION)
	_show_tween.tween_property(self, "scale", Vector2(0.8, 0.8), AnimationConstants.TOOLTIP_HIDE_DURATION)
	_show_tween.chain().tween_callback(func(): self.visible = false)


# Public API
func set_display_text(text: String) -> void:
	display_text = text
	if content_rich_text_label:
		# Resolve through tr() in case the caller supplies a translation key.
		content_rich_text_label.text = tr(text)