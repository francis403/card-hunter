extends GenericWorldNode
class_name TreasureWorldNode

const REVEALED_NODE_SPRITE = preload("res://assets/images/nodes/chest_nodet.png")
const UNKOWN_NODE_SPRITE = preload("res://assets/images/nodes/question_mark_node-transparent.png")
const TREASURE_SCENE = preload("res://ui/screens/world_node_screens/treasure_world_node_screen/treasure_world_node_screen.tscn")

var has_node_been_activated: bool = false

## -------- OVERRIDE IMNPORTANT FUNCTIONS --------
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/treasure_world_node/treasure_world_node.tscn"

func reveal_node_effect():
	world_node_sprite.texture = REVEALED_NODE_SPRITE

func on_node_click_event():
	if self.has_node_been_activated:
		return
	self.has_node_been_activated = true
	var treasure_scene: TreasureWorldNodeScreen  = generate_treasure_scene()
	get_tree().root.add_child(treasure_scene)

func generate_treasure_scene() -> TreasureWorldNodeScreen:
	var scene: TreasureWorldNodeScreen = TREASURE_SCENE.instantiate()
	scene.tree_exited.connect(_on_scene_exited_signal)
	return scene

func after_node_is_ready():
	if self.is_revealed:
		world_node_sprite.texture = REVEALED_NODE_SPRITE
	else:
		world_node_sprite.texture = UNKOWN_NODE_SPRITE
	
## -------- FINISH OVERRIDING IMNPORTANT FUNCTIONS --------

func _on_scene_exited_signal():
	BattlemapSignals.node_completed_and_freed.emit(self.world_node_id)
