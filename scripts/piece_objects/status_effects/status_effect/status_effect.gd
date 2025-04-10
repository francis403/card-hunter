extends Node
class_name StatusEffect

@export var id: String = ""
@export var description: String = "Test description"
@export var status_icon: Texture2D

@export var status_effect_config: StatusEffectConfig

var target: Piece

func _ready() -> void:
	target = get_parent().get_parent()

func on_effect_gain():
	pass

func apply_effect():
	pass
	
func on_effect_discarded():
	pass
