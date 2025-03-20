extends Menu

signal volume_change(new_volume: float)

@onready var _volume_slider: HSlider = $VBoxContainer/GridContainer/VolumeSlider

func _ready() -> void:
	_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	
func _on_volume_slider_value_changed(value: float) -> void:
	File.settings.volume = value
	Music.set_linear_volume(value)
	volume_change.emit(value)


func _on_back_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
