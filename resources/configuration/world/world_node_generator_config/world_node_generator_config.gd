extends Resource

## Defines how a specific type of World Node being generated
class_name WorldNodeGeneratorConfig

@export var node_scene: PackedScene
@export var weight: int = 0
@export var min_ocurrences: int = 0
@export var max_ocurrences: int = 100
@export var minimum_distance_to_root: int = 0
@export var maximimum_distance_to_root: int = 100
