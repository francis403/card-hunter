extends VBoxContainer
class_name ClassPickerComponent

signal class_picker_clicked(_instance: ClassPickerComponent)

@onready var card_back: CardBack = $CardBack
@onready var title_label: Label = %Title
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var card_back_texture: AtlasTexture
@export var title: String
@export var player_class: PlayerClass

@export var is_locked: bool = false

@export_group("OnClick Configuration")
@export var _enable_click: bool = true
@export var _enable_default_onclick_event: bool = true

func _ready() -> void:
	card_back.update_card_back_image(card_back_texture)
	title_label.text = title

func update_ui(
	_player_class: PlayerClass
):
	title_label.text = _player_class.player_class_name
	card_back.update_card_back_image(_player_class.player_class_icon)

func _on_card_back_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and _enable_click:
		if not _enable_default_onclick_event:
			return
		if player_class:
			PlayerController.replace_deck(player_class.default_class_deck)
		audio_stream_player.play()
		await audio_stream_player.finished
		class_picker_clicked.emit(self)
