extends Resource
class_name CardResource

enum AFFECTS_ENUM {SELF, MONSTER}
enum AREA_TYPE {NONE, SPECIFIC, LINE, RADIUS, CROSS, SHOTGUN}

@export var id: String
@export var title: String
@export_multiline var description: String
@export var target: AFFECTS_ENUM = AFFECTS_ENUM.SELF
@export var area_type: AREA_TYPE = AREA_TYPE.NONE
@export var max_distance: int = 0

# TODO: not sure if it isn't smarter to do different card_resource types
#	such as: MoveCardResource & AttackCardResource
@export var damage_done: int = 0

#TODO: maybe do a different card type just for condition for effect to trigger
#	Or we could just add it in the controller

# TODO: maybe I don't need a packed scene here
@export var card_ability_controller_scene: PackedScene
