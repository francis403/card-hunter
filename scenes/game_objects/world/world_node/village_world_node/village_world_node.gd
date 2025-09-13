extends GenericWorldNode
class_name VillageWorldNode


## -------- OVERRIDE IMNPORTANT FUNCTIONS --------
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/village_world_node/village_world_node.tscn"

func reveal_node_effect():
	pass

func on_node_click_event():
	pass

func after_node_is_ready():
	world_node_sprite.texture = self.revealed_texture
	world_node_sprite.scale = Vector2(2, 2)

## -------- FINISH OVERRIDING IMNPORTANT FUNCTIONS --------
