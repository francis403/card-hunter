extends Node2D
class_name HurtboxComponent

@export var sprite_2d: Sprite2D

@export_group("Behaviour configuration")
@export var play_flash: bool = true
@export var show_damage: bool = true

var floating_text_scene = preload("res://scenes/ui/pop_ups/floating_text.tscn")

func trigger(
	text: String = ""
) -> void:
	if play_flash:
		_play_hit_flash()
	if show_damage and not text.is_empty():
		_show_damage_label(text)

func _play_hit_flash():
	if sprite_2d and sprite_2d.material:
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

func _show_damage_label(damage: String):
	var floating_text = floating_text_scene.instantiate() as Node2D
	self.get_parent().add_child(floating_text)
	
	floating_text.global_position = self.global_position + (Vector2.UP * 32)
	
	#var format_string = "%0.1f"
	#if round(damage) == damage:
		#format_string = "%0.0f"
	#floating_text.start(str(format_string % damage))
	floating_text.start(damage)
