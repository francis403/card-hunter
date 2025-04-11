extends Resource
class_name StatusEffectConfig

@export var number_of_turns: int = 1

## When the effect is added to a tile, if a piece is there apply it immediatly
@export var apply_on_tile_added_to_pieces: bool = true
