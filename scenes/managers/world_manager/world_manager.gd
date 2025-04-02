extends Node
class_name WorldManager

func _ready() -> void:
	BattlemapSignals.reveal_connected_nodes.connect(_on_reveal_connected_nodes_signal)
	print(_ready)

func _on_reveal_connected_nodes_signal(world_node: WorldNode):
	for node in world_node.connections:
		BattlemapSignals.reveal_node.emit(node.world_node_id)
