extends TextureButton
class_name ImageButton

signal on_button_pressed

@export var _texture: Texture2D
@export var _audio_stream: AudioStream
@export var _under_text: String

@onready var front_image: TextureRect = $FrontImage
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var text_label: Label = $Text

func _ready() -> void:
	if _texture:
		front_image.texture = _texture
	if _audio_stream:
		audio_stream_player.stream = _audio_stream
	if _under_text:
		text_label.text = _under_text
	self.pressed.connect(_on_button_pressed)


func _on_button_pressed():
	if audio_stream_player.stream:
		audio_stream_player.play()
		await audio_stream_player.finished
	on_button_pressed.emit()
