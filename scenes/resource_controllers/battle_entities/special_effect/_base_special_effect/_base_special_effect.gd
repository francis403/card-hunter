extends Node
class_name BaseSpecialEffect

## reference to the card this special effect is  related to
var card: Card = null

func _init_special_effect(
	_card: Card,
	_special_card_effect_resource: SpecialCardEffectResource
):
	pass

func _ready() -> void:
	_on_ready_special_effect()

## Every Special effect does something, this representes the something
func do_effect():
	pass

func _on_ready_special_effect():
	pass
	
func prepare_special_effect():
	pass
