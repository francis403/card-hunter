extends Node

@export_group("Images")
@export var locked_card_back_texture: Texture

@export_group("Components Scenes")
@export var weapon_picker_component_scene: PackedScene
@export var tooltip_component_scene: PackedScene
@export var event_subscreen: PackedScene

@export_group("Screens Scenes")
@export var deforge_card_screen_scene: PackedScene
@export var deck_visualizer_scene: PackedScene
@export var generic_battle_scene: PackedScene

@export_group("Event Resources")
@export var thank_you_event_scene: EventConfig
@export var new_village_event_scene: EventConfig
