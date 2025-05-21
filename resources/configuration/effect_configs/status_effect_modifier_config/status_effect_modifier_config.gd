extends Resource
class_name StatusEffectModifierConfig

enum StatusEffectTypes {
	REMOVE_ALL,
	REMOVE_ID,
	STRENGHT_MODIFIER,
	SPEED_MODIFIER,
	OTHER
}

@export var stat: StatusEffectModifierConfig.StatusEffectTypes
@export var value: float = 1.0
@export var other_scene_controller: PackedScene

## TODO: Get power based on which Status effect is chosen
func _get_status_effect_instance() -> StatusEffect:
	var generic_status_effect_controller: GenericStatusEffectController = GenericStatusEffectController.new()
	generic_status_effect_controller
	match stat:
		StatusEffectTypes.STRENGHT_MODIFIER:
			return null
	return null
