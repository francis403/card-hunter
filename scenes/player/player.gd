extends PlayerPiece
class_name PlayerCharacter

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var status_effect_container: StatusEffectContainer = $StatusEffectContainer
@onready var status_effects_ui: StatusEffectUI = $StatusEffectsUI

func _ready() -> void:
	super._ready()
	BattlemapSignals.play_card_stream.connect(_on_play_card_sound_signal)

func _on_play_card_sound_signal(audio_stream: AudioStream):
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
func add_status(status: StatusEffect):
	status_effect_container.add_status(status, self)

func has_any_status() -> bool:
	return status_effect_container.has_any_status()

func has_status(status_id: String) -> bool:
	return status_effect_container.has_status(status_id)

## TODO: improve this
func remove_status(status_id: String):
	status_effect_container.remove_status(status_id)
