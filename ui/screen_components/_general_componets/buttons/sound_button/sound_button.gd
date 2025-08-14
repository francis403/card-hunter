extends Button
class_name SoundButton

signal pressed_and_sound_played

@onready var random_stream_player_component: AudioStreamPlayer = $RandomStreamPlayerComponent

func _ready() -> void:
	pressed.connect(on_pressed)
	

func on_pressed():
	random_stream_player_component.play_random()
	await random_stream_player_component.finished
	pressed_and_sound_played.emit()
