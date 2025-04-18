extends Node
class_name StatusEffect

@export var id: String = ""
@export var description: String = "Test description"
@export var status_icon: Texture2D

@export var status_effect_config: StatusEffectConfig

var target: Piece

func _ready() -> void:
	target = get_parent().get_parent()
	self.on_effect_gain()

## Happens when the effect is added to the piece (only trigger once)
func on_effect_gain():
	pass

## what happens when the effect is applied (only trigger once)
func apply_effect():
	pass
	
## What happens when the effect is triggered (can be multiple times )
func on_effect_triggered():
	pass

## What happens when the effect is discarded (only triggered once)
func on_effect_discarded():
	pass
