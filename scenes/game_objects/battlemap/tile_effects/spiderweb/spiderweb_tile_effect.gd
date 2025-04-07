extends TileEffect

## When player steps on spiderweb the next movement he plays is canceled
class_name SpiderwebTileEffect

const STOP_NEXT_MOVEMENTS_STATUS = preload("res://scenes/game_objects/status_effects/stop_next_movements/StopNextMovements.tscn")
#
func apply_effect(piece: Piece):
	print("apply tile effect")
	piece.add_status(STOP_NEXT_MOVEMENTS_STATUS.instantiate())
