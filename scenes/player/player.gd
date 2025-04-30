extends PlayerPiece
class_name PlayerCharacter

const PLAYER_HIT_1 = preload("res://assets/sound/sound_effects/player_hit_1.mp3")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var status_effect_container: StatusEffectContainer = $StatusEffectContainer
@onready var status_effects_ui: StatusEffectUI = $StatusEffectsUI
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	if PlayerController.current_player_health >= 0:
		self._health = PlayerController.current_player_health
	else:
		PlayerController.current_player_health = self._health
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

func remove_all_status():
	status_effect_container.remove_all_status()

## TODO: improve this
func remove_status(status_id: String):
	status_effect_container.remove_status(status_id)

func apply_damage(damage: int):
	_play_hit_flash()
	audio_stream_player.stream = PLAYER_HIT_1
	audio_stream_player.play()
	super.apply_damage(damage)

func _play_hit_flash():
	if sprite_2d.material:
		var tween = create_tween()
		tween.tween_method(
			set_flash_modifier,
			1.0,
			0.0,
			0.2
		)

func set_flash_modifier(value: float) -> void:
	if sprite_2d.material:
		sprite_2d.material.set_shader_parameter("flash_modifier", value)
