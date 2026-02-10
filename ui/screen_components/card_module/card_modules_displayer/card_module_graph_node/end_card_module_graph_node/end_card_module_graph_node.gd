extends GraphNode
class_name EndCardModuleGraphNode

func _ready() -> void:
	# End node: input only (no output port)
	# Purple color matching original EndCardModule
	set_slot(0, true, 0, Color(0.21, 0.15, 0.4), false, 0, Color.WHITE)
