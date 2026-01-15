extends Screen
class_name SettingsScreen

signal volume_change(new_volume: float)

@onready var _volume_slider: HSlider = %VolumeSlider


func _ready() -> void:
	_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	
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


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_save_button_pressed() -> void:
	File.save()
