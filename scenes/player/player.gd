extends PlayerPiece
class_name PlayerCharacter

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var status_container: Node = $StatusContainer


func _ready() -> void:
	super._ready()
	BattlemapSignals.play_card_stream.connect(_on_play_card_sound_signal)

func _on_play_card_sound_signal(audio_stream: AudioStream):
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
func add_status(status: StatusEffect):
	status_container.add_child(status)
