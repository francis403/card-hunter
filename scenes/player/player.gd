extends PlayerPiece
class_name PlayerCharacter

const PLAYER_HIT_1 = preload("res://assets/sound/sound_effects/player_hit_1.mp3")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var power_effect_container: PowerEffectContainer = $PowerEffectContainer

## Shows the player which power effects are applied to him.
@onready var power_effect_ui: PowerEffectUI = $PowerEffectUI

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

func add_power_effect(power_effect: BasePowerNodeController):
	power_effect_container.add_power_effect(power_effect, self)

func has_any_power_effect() -> bool:
	return power_effect_container.has_any_power_effect()

func has_power_effect(status_id: String) -> bool:
	return power_effect_container.has_power_effect(status_id)

func remove_all_power_effects():
	power_effect_container.remove_all_power_effects()

## TODO: improve this
func remove_power_effect(status_id: String):
	power_effect_container.remove_power_effect(status_id)

func apply_damage(
	damage: int,
	_origin_tile: Tile
):
	if not self.is_player_damageable:
		return
	_play_hit_flash()
	audio_stream_player.stream = PLAYER_HIT_1
	audio_stream_player.play()
	super.apply_damage(damage, _origin_tile)

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
