extends GenericWorldNode
class_name TreasureWorldNode

## -------- OVERRIDE IMNPORTANT FUNCTIONS --------
func set_world_scene():
	my_node_scene_path = "res://scenes/game_objects/world/world_node/treasure_world_node/treasure_world_node.tscn"
	
## -------- FINISH OVERRIDING IMNPORTANT FUNCTIONS --------

func _on_scene_exited_signal():
	BattlemapSignals.node_completed_and_freed.emit(self.world_node_id)
