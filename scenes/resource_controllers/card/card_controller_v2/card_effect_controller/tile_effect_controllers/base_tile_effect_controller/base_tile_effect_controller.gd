extends Node
class_name BaseTileEffectController

@onready var texture_rect: TextureRect = $TextureRect

##TODO: Update

var tile_effect_resource: TileEffectResource

func _ready() -> void:
	if tile_effect_resource.tile_effect_icon:
		texture_rect.texture = tile_effect_resource.tile_effect_icon

func apply_effect(piece: Piece):
	if not tile_effect_resource.power_effect:
		return
	var power_controller: BasePowerNodeController =\
		tile_effect_resource.power_effect.base_power_node.instantiate()
	power_controller.power_effect_resource = tile_effect_resource.power_effect
	
	## TODO: this seems like a terrible practice
	if power_controller:
		piece.add_power_effect(
			power_controller.power_effect_resource.init_base_power_node(piece)
		)
	self.queue_free()
