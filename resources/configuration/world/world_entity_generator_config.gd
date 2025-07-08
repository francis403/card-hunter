extends Resource
class_name WorldEntityGeneratorConfig

@export var node_scene: PackedScene
@export var weight: int = 0
## TODO: need to find a way to add this
#@export var min_ocurrences: int = 0
@export var max_ocurrences: int = 100
@export var minimum_distance_to_root: int = 0
@export var maximimum_distance_to_root: int = 100

func generate() -> Object:
	if not node_scene:
		return null
	return node_scene.instantiate().duplicate()
