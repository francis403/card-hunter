extends Node
class_name StatusEffect

@export var id: String = ""

@export var description: String = "Test description"

## Target of the status (TODO: probably don't need this)
@export var piece: Piece

@export var status_icon: Texture2D

func on_effect_gain():
	pass

func apply_effect():
	pass
	
func on_effect_discarded():
	pass
