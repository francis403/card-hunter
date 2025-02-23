extends Resource
class_name CardResource

@export var id: String
@export var title: String
@export_multiline var description: String
@export var target: Constants.TargetType = Constants.TargetType.SELF
@export var area_type: Constants.AreaType = Constants.AreaType.NONE
@export var max_distance: int = 0

# TODO: not sure if it isn't smarter to do different card_resource types
#	such as: MoveCardResource & AttackCardResource
@export var damage_done: int = 0

#TODO: maybe do a different card type just for condition for effect to trigger
#	Or we could just add it in the controller

# TODO: Have some sort of extra info in the cards
#	Might even have the controller inside the category cards
@export var card_categories: Array[CardCategory] = []

# TODO: maybe I don't need a packed scene here
@export var card_ability_controller_scene: PackedScene
