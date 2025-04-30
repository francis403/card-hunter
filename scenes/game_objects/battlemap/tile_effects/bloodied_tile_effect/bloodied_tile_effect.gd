extends TileEffect
class_name BloodiedTileEffect

const STATUS_EFFECT_SCENE: PackedScene = preload("res://scenes/game_objects/status_effects/effects/bloodied_status_effect/bloodied_status_effect_controller.tscn")

func apply_effect(piece: Piece):
	var status_effect: StatusEffect = STATUS_EFFECT_SCENE.instantiate()
	status_effect.target = piece
	piece.add_status(status_effect)
	self.queue_free()
