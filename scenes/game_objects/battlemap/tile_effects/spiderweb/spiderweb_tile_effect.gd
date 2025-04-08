extends TileEffect

## When player steps on spiderweb the next movement he plays is canceled
class_name SpiderwebTileEffect

const STOP_NEXT_MOVEMENTS_STATUS = preload("res://scenes/game_objects/status_effects/stop_next_movements/stop_next_movement.tscn")

func apply_effect(piece: Piece):
	var stop_next_movement_status: StopNextMovements = STOP_NEXT_MOVEMENTS_STATUS.instantiate()
	stop_next_movement_status.piece = piece
	piece.add_status(stop_next_movement_status)
	self.queue_free()
