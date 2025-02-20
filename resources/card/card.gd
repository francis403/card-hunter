extends Resource
class_name CardResource

enum AFFECTS_ENUM {SELF, MONSTER}

@export var id: String
@export var title: String
@export_multiline var description: String
@export var affects: AFFECTS_ENUM = AFFECTS_ENUM.SELF
@export var max_distance: int = 0

# TODO: maybe I don't need a packed scene here
@export var card_ability_controller_scene: PackedScene
