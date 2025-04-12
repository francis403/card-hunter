extends EventCategory
class_name PowerCategoryCard

## Stores the StatusEffect Controller
@export var power_controller: PackedScene

## The number of turns this power lasts. -1 for forever
@export var status_event_config: StatusEffectConfig = StatusEffectConfig.new()
