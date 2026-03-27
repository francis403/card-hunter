extends GraphNode
class_name BaseCardModuleGraphNode

signal module_closed(_module: BaseCardModuleGraphNode)

var max_number_of_input_connections: int = 1
var max_number_of_output_connections: int = 1

func toggle_close_button(_value: bool):
	pass
