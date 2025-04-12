extends Control
class_name MainWorldScreen

@onready var world_nodes: MarginContainer = $WorldNodes

func _ready() -> void:
	_clean_preview()

func _clean_preview():
	for child in world_nodes.get_children():
		child.queue_free()
