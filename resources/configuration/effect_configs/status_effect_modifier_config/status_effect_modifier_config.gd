extends Resource
class_name StatusEffectModifierConfig

enum StatusEffectTypes {
	REMOVE_ALL,
	REMOVE_ID,
	STRENGHT_MODIFIER,
	SPEED_MODIFIER
}

@export var stat: StatusEffectModifierConfig.StatusEffectTypes
@export var value: float = 1.0
