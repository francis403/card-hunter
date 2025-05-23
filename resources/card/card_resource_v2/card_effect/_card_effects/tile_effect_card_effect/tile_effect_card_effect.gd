extends CardEffectWithUserInput
class_name TileEffectCardEffect

const BASE_TILE_EFFECT_CONTROLLER = preload("res://scenes/resource_controllers/card/card_controller_v2/card_effect_controller/tile_effect_controllers/base_tile_effect_controller/base_tile_effect_controller.tscn")

## TODO: do we need an id?
@export var id: String

## This is the effect that will be added to the piece when it enters the tile
@export var power_effect: PowerEffect

## This is the visual change to the tile
@export var tile_effect_icon: Texture2D

## TODO: Either use something like the TileEffect class or create a BaseTileEffectController class
## This is what controls what triggers the apply_effect function & adds the power_effect to the piece
@export var tile_effect_controller: PackedScene = BASE_TILE_EFFECT_CONTROLLER


func card_effect():
	if target_tile == null:
		return
	if not tile_effect_controller:
		return
	var tile_effect_controller: BaseTileEffectController = init_tile_effect_controller()
	target_tile.add_tile_effect_v2(
		tile_effect_controller
	)

func init_tile_effect_controller() -> BaseTileEffectController:
	var result: BaseTileEffectController = tile_effect_controller.instantiate()
	result.tile_effect_card_effect = self
	return result
