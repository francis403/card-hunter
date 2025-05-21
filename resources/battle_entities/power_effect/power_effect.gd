extends Resource

## TODO: will need to get the peice this is attached to somehow
class_name PowerEffect

const BASE_POWER_NODE_CONTROLLER: PackedScene = preload("res://scenes/resource_controllers/card/card_controller_v2/card_effect_controller/power_effect_controllers/base_power_node_controller/base_power_node_controller.tscn")

@export_group("Basic Power Effect Info")
@export var id: String
@export var title: String
@export var description: String

@export_group("Power Duration")
@export var is_never_ending: bool = false
## Only works if is_never_ending is false
@export var turns_duration: int = 2

## Will be responsible for reading all the behaviours underneath it.
## Feel free to change if we need more specific behaviour
@export_group("Power Behaviour")
##	This node will need to be added to the target piece.
## Needs to be a PowerNodeController
@export var base_power_node: PackedScene = BASE_POWER_NODE_CONTROLLER
## This nodes will, by default, be added to the base_power_node.
## Change the function add_to_base_power_node functionality if you wish to modify it
@export var trigger_effect_event: Array[TriggerEffectEventResource]

## TODO: get target piece
func init_base_power_node() -> BasePowerNodeController:
	var result = base_power_node.instantiate()
	for trigger_effect in trigger_effect_event:
		trigger_effect._init_trigger_effect(null)
	return result
	
