extends Control
class_name Screen

var is_open: bool = false

func open_screen(parent_node: Node):
	parent_node.add_child(self)
	#Callable(parent_node.add_child).call_deferred(self)
	if get_tree():
		get_tree().paused = true
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func close_screen():
	get_tree().paused = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	self.queue_free()
