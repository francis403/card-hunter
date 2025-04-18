extends Resource

## This can be applied to:
## - Cards (on play)
## - Tile Effects (on trigger/ on other triggers)
## - Status Effects (whenever we want)
class_name EffectExtraCostConfig

enum ExtraCostStat {
	STAMINA,
	HEALTH,
	SPEED
}

enum ExtraCostTiming {
	ON_SELF_PLAYED,
	ON_EVERY_CARD_PLAY,
	ON_STATUS_APPLIED,
	ON_STATUS_REMOVED
}

@export var extra_cost_stat: ExtraCostStat
@export var extra_cost_timing: ExtraCostTiming
@export var extra_cost_operation: StatusModifierConfig

## Only used if extra_cost_operation not defined.
## Value to subtract from stamina.
@export var stamina_cost_operation: int = -10
