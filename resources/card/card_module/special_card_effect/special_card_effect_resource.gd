extends CardModule

## Triggers special effect 
## Represents a module of the card that is triggered on a specific trigger
class_name SpecialCardEffectResource

## Contains a SpecialEffectController
## TODO: Do I need this?
@export var controller: PackedScene

@export_group("Card Module Color Configuration")
@export var top_section_background_color: Color = Color(0, 0.2, 0.4)
@export var bottom_section_background_color: Color = Color(0.204, 0.596, 0.859)

func _get_my_node_scene_path() -> String:
	return "res://resources/card/card_module/special_card_effect/special_card_effect_resource.gd"
