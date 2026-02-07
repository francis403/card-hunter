extends Screen
class_name SettingsScreen

signal volume_change(new_volume: float)

@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _language_option_button: OptionButton = %LanguageOptionButton

var _language_codes: Array[String] = []

func _ready() -> void:
	_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_language_option_button.item_selected.connect(_on_language_option_selected)
	_setup_language_options()
	LocalizationController.language_changed.connect(_on_language_changed)

func _setup_language_options() -> void:
	_language_option_button.clear()
	_language_codes.clear()
	var languages = LocalizationController.get_supported_languages()
	var current_locale = LocalizationController.current_locale
	var selected_index = 0
	var index = 0
	for locale in languages.keys():
		_language_option_button.add_item(languages[locale])
		_language_codes.append(locale)
		if locale == current_locale:
			selected_index = index
		index += 1
	_language_option_button.select(selected_index)

func _on_language_option_selected(index: int) -> void:
	if index >= 0 and index < _language_codes.size():
		LocalizationController.set_language(_language_codes[index])

func _on_language_changed(_new_locale: String) -> void:
	_update_labels()

func _update_labels() -> void:
	pass

func _on_volume_slider_value_changed(value: float) -> void:
	File.settings.volume = value
	Music.set_linear_volume(value)
	volume_change.emit(value)
	File.change_settings()

func _on_back_button_pressed() -> void:
	ScreenUtils.close_settings_screen()

func open_screen(parent_node: Node):
	super.open_screen(parent_node)
	self._volume_slider.value = File.settings.volume
	_setup_language_options()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_save_button_pressed() -> void:
	File.save()

func _on_title_menu_button_pressed_and_sound_played() -> void:
	_remove_current_battle_scene()
	get_tree().change_scene_to_packed(Refs.title_scene)
	get_tree().paused = false
	self.queue_free()

func _remove_current_battle_scene():
	if GameController.current_battle_scene:
		GameController.current_battle_scene.queue_free()
		GameController.current_battle_scene = null
