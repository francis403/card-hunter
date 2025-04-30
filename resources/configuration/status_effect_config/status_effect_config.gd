extends Resource

## TODO: maybe rename this to effect_config
class_name StatusEffectConfig


@export var number_of_turns: int = 1

## When the effect is added to a tile, if a piece is there apply it immediatly
@export var apply_on_tile_added_to_pieces: bool = true

@export_group("Extra cost")
@export var extra_cost: EffectExtraCostConfig

## Do you want to modify a specific status when the status
@export_group("Modify a stat, or status effect")
@export var status_modifier_config: StatusModifierConfig
## TODO: DO I want this for the status effect config? 
@export var status_effect_modifier_config: StatusEffectModifierConfig


@export_group("When the effect is triggered")
@export var effect_trigger: Constants.EffectTrigger
