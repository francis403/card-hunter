extends Node
class_name WorldManager

## counts all nodes currently being revealed
var _nodes_left_to_reveal: int = 0

func _ready() -> void:
	BattlemapSignals.reveal_connected_nodes.connect(_on_reveal_connected_nodes_signal)
	BattlemapSignals.node_finished_revealing.connect(_on_node_finished_revealing_signal)
	print(_ready)

func _on_reveal_connected_nodes_signal(world_node: WorldNode):
	for node in world_node.connections:
		BattlemapSignals.reveal_node.emit(node.world_node_id)
		_nodes_left_to_reveal += 1

func _on_node_finished_revealing_signal(world_node_id: String):
	_nodes_left_to_reveal -= 1
	if _nodes_left_to_reveal == 0:
		BattlemapSignals.world_updated.emit()
