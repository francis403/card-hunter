extends ContainerScreen
class_name EventSubScreen

signal on_event_button_pressed(button_config: EventButtonConfig)
signal on_button_action_signal(button_id: String)

const SOUND_BUTTON_SCENE = preload("res://ui/screen_components/_general_componets/buttons/sound_button/sound_button.tscn")

@export var event_config: EventConfig

var _button_config_map: Dictionary = {}  # SoundButton -> EventButtonConfig

func _ready() -> void:
	super._ready()
	_setup_from_config()

func _setup_from_config() -> void:
	if not event_config:
		return

	title_label.text = event_config.title
	description_label.text = event_config.description
	_create_buttons_from_config()

func setup_with_config(config: EventConfig) -> void:
	event_config = config
	if is_inside_tree():
		title_label.text = event_config.title
		description_label.text = event_config.description
		_create_buttons_from_config()

func _create_buttons_from_config() -> void:
	if not event_config:
		return

	var button_configs = event_config.get_button_configs()
	if button_configs.is_empty():
		return

	# Hide default close button when using config buttons
	close_button.visible = false

	# Sort by order
	var sorted_configs = button_configs.duplicate()
	sorted_configs.sort_custom(func(a, b): return a.order < b.order)

	# Create buttons
	for config in sorted_configs:
		if not config.visible:
			continue

		var button: SoundButton = SOUND_BUTTON_SCENE.instantiate()
		button.text = config.button_text
		button.disabled = config.disabled
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Store mapping
		_button_config_map[button] = config

		# Connect signal
		button.pressed_and_sound_played.connect(_on_config_button_pressed.bind(button))

		h_box_button_container.add_child(button)

func _on_config_button_pressed(button: SoundButton) -> void:
	var config: EventButtonConfig = _button_config_map.get(button)
	if not config:
		push_warning("EventSubScreen: Button config not found")
		return

	# Emit pressed signal
	on_event_button_pressed.emit(config)

	# Handle disable_after_press
	if config.disable_after_press:
		button.disabled = true

	# Execute action
	var should_close: bool = true
	if config.action:
		if config.action.can_execute(self):
			should_close = config.action.execute(self)

	# Close screen if action says so
	if should_close:
		queue_free()
