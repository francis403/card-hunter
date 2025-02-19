extends Resource
class_name CardResource

@export var id: String
@export var title: String
@export_multiline var description: String

# TODO: maybe I don't need a packed scene here
@export var card_ability_controller_scene: PackedScene
