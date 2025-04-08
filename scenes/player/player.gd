extends PlayerPiece
class_name PlayerCharacter

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var status_container: Node = $StatusContainer
@onready var status_effects_ui: StatusEffectUI = $StatusEffectsUI

func _ready() -> void:
	super._ready()
	BattlemapSignals.play_card_stream.connect(_on_play_card_sound_signal)

func _on_play_card_sound_signal(audio_stream: AudioStream):
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
func add_status(status: StatusEffect):
	status.piece = self
	status_container.add_child(status)
	status_effects_ui.add_status_effect_indicator(status)

## TODO: improve this
func remove_status(status_id: String):
	for child in status_effects_ui.get_status_indicator_children():
		if child.status_effect.id == status_id:
			child.queue_free()
			return
